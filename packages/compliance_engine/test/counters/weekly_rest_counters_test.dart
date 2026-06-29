import 'package:compliance_engine/compliance_engine.dart';
import 'package:compliance_engine/src/counters/reduced_weekly_rests_counter.dart';
import 'package:compliance_engine/src/counters/weekly_rest_compensation_counter.dart';
import 'package:compliance_engine/src/counters/weekly_rest_counter.dart';
import 'package:test/test.dart';

import '../support/builder.dart';

void main() {
  group('WeeklyRestCounter', () {
    test('happy: within the 6x24h window, weekly rest action raised', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.rest, 1440), // 24h weekly rest -> anchor
        (ActivityType.driving, 600),
      ]));
      final r = const WeeklyRestCounter().compute(ctx);
      expect(r.status.used, mins(600));
      expect(r.violations, isEmpty);
      expect(r.actions.single.type, RequiredActionType.takeWeeklyRest);
    });

    test('violation: working past the 6x24h window', () {
      final ctx = context(timeline(utc(2026, 6, 1, 0), [
        (ActivityType.rest, 1440),
        (ActivityType.driving, 8700), // > 144h since the weekly rest
      ]));
      final r = const WeeklyRestCounter().compute(ctx);
      expect(r.status.used, mins(8700));
      expect(r.violations.single.counter, CounterType.weeklyRest);
    });
  });

  group('ReducedWeeklyRestsCounter', () {
    test('happy: one reduced weekly rest in the fortnight', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 1440), // 24h reduced weekly rest
        (ActivityType.driving, 60),
      ]));
      final r = const ReducedWeeklyRestsCounter().compute(ctx);
      expect(r.status.count, 1);
      expect(r.violations, isEmpty);
    });

    test('violation: two reduced weekly rests in the fortnight', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 1440),
        (ActivityType.driving, 60),
        (ActivityType.rest, 1440),
        (ActivityType.driving, 60),
      ]));
      final r = const ReducedWeeklyRestsCounter().compute(ctx);
      expect(r.status.count, 2);
      expect(r.violations.single.counter, CounterType.reducedWeeklyRests);
    });
  });

  group('WeeklyRestCompensationCounter', () {
    test('owes compensation after a reduced weekly rest', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 1440), // 24h -> owes 45h - 24h = 21h
        (ActivityType.driving, 60),
      ]));
      final r = const WeeklyRestCompensationCounter().compute(ctx);
      expect(r.status.used, mins(1260));
      expect(r.status.level, ComplianceLevel.approaching);
    });

    test('no compensation owed after a regular weekly rest', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 2700), // 45h regular weekly rest
        (ActivityType.driving, 60),
      ]));
      final r = const WeeklyRestCompensationCounter().compute(ctx);
      expect(r.status.used, Duration.zero);
      expect(r.status.level, ComplianceLevel.ok);
    });

    test('nets excess rest against owed compensation', () {
      final ctx = context(timeline(utc(2026, 6, 8, 0), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 1440), // reduced -> owes 1260
        (ActivityType.driving, 60),
        (ActivityType.rest, 3600), // 60h -> credit 900
        (ActivityType.driving, 60),
      ]));
      final r = const WeeklyRestCompensationCounter().compute(ctx);
      expect(r.status.used, mins(360)); // 1260 - 900
    });

    test('compensation past the deadline is no longer outstanding', () {
      final ctx = context(timeline(utc(2026, 5, 1, 0), [
        (ActivityType.driving, 60),
        (ActivityType.rest, 1440), // reduced weekly rest ~5 weeks before now
        (ActivityType.driving, 54000),
      ]));
      final r = const WeeklyRestCompensationCounter().compute(ctx);
      expect(r.status.used, Duration.zero);
    });
  });
}
