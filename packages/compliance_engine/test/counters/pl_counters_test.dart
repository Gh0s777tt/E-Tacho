import 'package:compliance_engine/compliance_engine.dart';
import 'package:compliance_engine/src/counters/night_work_counter.dart';
import 'package:compliance_engine/src/counters/weekly_working_time_counter.dart';
import 'package:test/test.dart';

import '../support/builder.dart';

void main() {
  group('WeeklyWorkingTimeCounter (PL)', () {
    test('happy: working time under 60h', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 1800),
        (ActivityType.otherWork, 1000),
      ]));
      final r = const WeeklyWorkingTimeCounter().compute(ctx);
      expect(r.status.used, mins(2800));
      expect(r.violations, isEmpty);
    });

    test('violation: working time beyond 60h', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 1800),
        (ActivityType.otherWork, 1900),
      ]));
      final r = const WeeklyWorkingTimeCounter().compute(ctx);
      expect(r.status.used, mins(3700));
      expect(r.violations.single.counter, CounterType.weeklyWorkingTime);
    });
  });

  group('NightWorkCounter (PL)', () {
    test('no night work: the 10h cap does not apply even past 10h', () {
      final ctx = context(timeline(utc(2026, 6, 9, 19), [
        (ActivityType.rest, 660), // 19:00 -> 06:00 next day (sets dutyStart)
        (ActivityType.driving, 650), // 06:00 -> 16:50, daytime only
      ]));
      final r = const NightWorkCounter().compute(ctx);
      expect(r.status.used, mins(650));
      expect(r.status.level, ComplianceLevel.ok);
      expect(r.violations, isEmpty);
    });

    test('night work under the cap: no violation', () {
      final ctx = context(timeline(utc(2026, 6, 9, 12), [
        (ActivityType.rest, 660), // dutyStart 23:00
        (ActivityType.driving, 300), // 23:00 -> 04:00, crosses 00:00-04:00 window
      ]));
      final r = const NightWorkCounter().compute(ctx);
      expect(r.status.used, mins(300));
      expect(r.violations, isEmpty);
    });

    test('violation: night work and working time beyond 10h', () {
      final ctx = context(timeline(utc(2026, 6, 9, 12), [
        (ActivityType.rest, 660), // dutyStart 23:00
        (ActivityType.driving, 300), // 23:00 -> 04:00 (night)
        (ActivityType.otherWork, 350), // 04:00 -> 09:50  => 650 min work
      ]));
      final r = const NightWorkCounter().compute(ctx);
      expect(r.status.used, mins(650));
      expect(r.violations.single.counter, CounterType.nightWork);
    });
  });
}
