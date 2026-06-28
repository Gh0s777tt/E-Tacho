import 'package:compliance_engine/compliance_engine.dart';
import 'package:compliance_engine/src/counters/daily_rest_counter.dart';
import 'package:compliance_engine/src/counters/duty_window_counter.dart';
import 'package:compliance_engine/src/counters/extended_driving_days_counter.dart';
import 'package:compliance_engine/src/counters/reduced_daily_rests_counter.dart';
import 'package:test/test.dart';

import '../support/builder.dart';

void main() {
  group('ExtendedDrivingDaysCounter', () {
    test('happy: two 10h days reach the cap but do not violate', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 600),
        (ActivityType.rest, 660),
        (ActivityType.driving, 600),
      ]));
      final r = const ExtendedDrivingDaysCounter().compute(ctx);
      expect(r.status.count, 2);
      expect(r.status.level, ComplianceLevel.critical);
      expect(r.violations, isEmpty);
    });

    test('violation: a third extended day in the week', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 600),
        (ActivityType.rest, 660),
        (ActivityType.driving, 600),
        (ActivityType.rest, 660),
        (ActivityType.driving, 600),
      ]));
      final r = const ExtendedDrivingDaysCounter().compute(ctx);
      expect(r.status.count, 3);
      expect(r.violations.single.counter, CounterType.extendedDrivingDays);
    });

    test('a day at or below 9h is not an extended day', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 500),
        (ActivityType.rest, 660),
        (ActivityType.driving, 600),
      ]));
      final r = const ExtendedDrivingDaysCounter().compute(ctx);
      expect(r.status.count, 1);
      expect(r.violations, isEmpty);
    });
  });

  group('DutyWindowCounter', () {
    test('happy: still inside the 24h window', () {
      final ctx = context(timeline(utc(2026, 6, 9, 0), [
        (ActivityType.rest, 660), // sets dutyStart
        (ActivityType.driving, 300),
      ]));
      final r = const DutyWindowCounter().compute(ctx);
      expect(r.status.used, mins(300));
      expect(r.violations, isEmpty);
      expect(r.actions.single.type, RequiredActionType.endDuty);
      expect(r.actions.single.timeUntil, mins(1440 - 300));
    });

    test('violation: still working past the 24h window', () {
      final ctx = context(timeline(utc(2026, 6, 9, 0), [
        (ActivityType.rest, 660),
        (ActivityType.driving, 1500),
      ]));
      final r = const DutyWindowCounter().compute(ctx);
      expect(r.status.used, mins(1500));
      expect(r.violations.single.counter, CounterType.dutyWindow);
    });

    test('no violation if the daily rest started before the window closed', () {
      final ctx = context(timeline(utc(2026, 6, 9, 0), [
        (ActivityType.rest, 660),
        (ActivityType.driving, 1400),
        (ActivityType.rest, 120), // started at 23h20 < 24h, still in progress
      ]));
      final r = const DutyWindowCounter().compute(ctx);
      expect(r.violations, isEmpty);
    });
  });

  group('DailyRestCounter', () {
    test('resting 5h: may resume work in 4h (after the 9h minimum)', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 300),
      ]));
      final r = const DailyRestCounter().compute(ctx);
      expect(r.status.used, mins(300));
      final action = r.actions.single;
      expect(action.type, RequiredActionType.mayResumeWork);
      expect(action.timeUntil, mins(240));
    });

    test('resting past 9h: may resume now', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 570),
      ]));
      final r = const DailyRestCounter().compute(ctx);
      expect(r.actions.single.timeUntil, Duration.zero);
    });

    test('not resting: no resume action', () {
      final ctx = context(timeline(utc(2026, 6, 10, 6), [
        (ActivityType.driving, 300),
      ]));
      final r = const DailyRestCounter().compute(ctx);
      expect(r.actions, isEmpty);
    });
  });

  group('ReducedDailyRestsCounter', () {
    test('happy: three reduced rests reach the cap', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 60),
      ]));
      final r = const ReducedDailyRestsCounter().compute(ctx);
      expect(r.status.count, 3);
      expect(r.violations, isEmpty);
    });

    test('violation: a fourth reduced rest', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 60),
      ]));
      final r = const ReducedDailyRestsCounter().compute(ctx);
      expect(r.status.count, 4);
      expect(r.violations.single.counter, CounterType.reducedDailyRests);
    });

    test('a regular (11h) rest is not counted as reduced', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 600),
        (ActivityType.rest, 660),
        (ActivityType.driving, 600),
        (ActivityType.rest, 540),
        (ActivityType.driving, 60),
      ]));
      final r = const ReducedDailyRestsCounter().compute(ctx);
      expect(r.status.count, 1);
      expect(r.violations, isEmpty);
    });
  });
}
