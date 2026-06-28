import 'package:compliance_engine/compliance_engine.dart';
import 'package:compliance_engine/src/counters/continuous_driving_counter.dart';
import 'package:compliance_engine/src/counters/daily_driving_counter.dart';
import 'package:compliance_engine/src/counters/fortnightly_driving_counter.dart';
import 'package:compliance_engine/src/counters/weekly_driving_counter.dart';
import 'package:test/test.dart';

import '../support/builder.dart';

void main() {
  group('ContinuousDrivingCounter', () {
    test('happy: under limit while driving raises a break action', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 180),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.used, mins(180));
      expect(r.status.remaining, mins(90));
      expect(r.violations, isEmpty);
      expect(r.actions.single.type, RequiredActionType.takeBreak);
      expect(r.actions.single.timeUntil, mins(90));
    });

    test('at 4.5h the break is due now (exceeded, not yet a violation)', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 270),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.level, ComplianceLevel.exceeded);
      expect(r.violations, isEmpty);
      expect(r.actions.single.timeUntil, Duration.zero);
    });

    test('violation: driving beyond 4.5h', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 285),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.violations.single.counter, CounterType.continuousDriving);
    });

    test('split break 15+30 resets the clock', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 120),
        (ActivityType.rest, 15),
        (ActivityType.driving, 120),
        (ActivityType.rest, 30),
        (ActivityType.driving, 10),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.used, mins(10));
    });

    test('after the first 15-min part, the second part is requested', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 120),
        (ActivityType.rest, 15),
        (ActivityType.driving, 60),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.used, mins(180));
      expect(r.actions.single.type,
          RequiredActionType.takeSplitBreakSecondPart);
    });

    test('a standalone 30-min rest does not reset (needs 45 or 15+30)', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 120),
        (ActivityType.rest, 30),
        (ActivityType.driving, 60),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.used, mins(180));
    });

    test('a full 45-min break resets the clock', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 200),
        (ActivityType.rest, 45),
        (ActivityType.driving, 30),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.used, mins(30));
    });

    test('other work pauses but does not reset the clock', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 120),
        (ActivityType.otherWork, 60),
        (ActivityType.driving, 60),
      ]));
      final r = const ContinuousDrivingCounter().compute(ctx);
      expect(r.status.used, mins(180));
    });
  });

  group('DailyDrivingCounter', () {
    test('happy: 8h driving, no violation', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 480),
      ]));
      final r = const DailyDrivingCounter().compute(ctx);
      expect(r.status.used, mins(480));
      expect(r.violations, isEmpty);
    });

    test('9h reaches the limit but is not a hard violation', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 540),
      ]));
      final r = const DailyDrivingCounter().compute(ctx);
      expect(r.status.level, ComplianceLevel.exceeded);
      expect(r.violations, isEmpty);
    });

    test('10h extended day is allowed (no hard violation)', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 600),
      ]));
      final r = const DailyDrivingCounter().compute(ctx);
      expect(r.violations, isEmpty);
    });

    test('violation: beyond the 10h ceiling', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 615),
      ]));
      final r = const DailyDrivingCounter().compute(ctx);
      expect(r.violations.single.counter, CounterType.dailyDriving);
    });
  });

  group('WeeklyDrivingCounter', () {
    test('happy: under 56h in the ISO week', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 600),
      ]));
      final r = const WeeklyDrivingCounter().compute(ctx);
      expect(r.status.used, mins(600));
      expect(r.violations, isEmpty);
    });

    test('violation: beyond 56h in the ISO week', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 3400),
      ]));
      final r = const WeeklyDrivingCounter().compute(ctx);
      expect(r.status.used, mins(3400));
      expect(r.violations.single.counter, CounterType.weeklyDriving);
    });
  });

  group('FortnightlyDrivingCounter', () {
    test('happy: under 90h across two weeks', () {
      final ctx = context(timeline(utc(2026, 6, 5, 0), [
        (ActivityType.driving, 600),
      ]));
      final r = const FortnightlyDrivingCounter().compute(ctx);
      expect(r.violations, isEmpty);
    });

    test('violation: beyond 90h across two consecutive weeks', () {
      final ctx = context(timeline(utc(2026, 6, 5, 0), [
        (ActivityType.driving, 5600),
      ]));
      final r = const FortnightlyDrivingCounter().compute(ctx);
      expect(r.status.used, mins(5600));
      expect(r.violations.single.counter, CounterType.fortnightlyDriving);
    });
  });
}
