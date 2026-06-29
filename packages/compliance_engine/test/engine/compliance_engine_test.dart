import 'package:compliance_engine/compliance_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../support/builder.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final engine = ComplianceEngine();

  ComplianceState evalUtc(
    ({List<ActivityEvent> events, DateTime now}) tl, {
    tz.Location? location,
  }) {
    return engine.evaluate(
      events: tl.events,
      rules: RulesPack.defaultEuPl,
      now: tl.now,
      timeZone: location ?? tz.UTC,
    );
  }

  test('empty history yields a benign state with every counter present', () {
    final state = engine.evaluate(
      events: const [],
      rules: RulesPack.defaultEuPl,
      now: utc(2026, 6, 10, 12),
      timeZone: tz.UTC,
    );
    expect(state.currentActivity, ActivityType.rest);
    expect(state.overall, ComplianceLevel.ok);
    expect(state.counters.length, CounterType.values.length);
    expect(state.violations, isEmpty);
  });

  test('4.5h continuous driving: overdue break, overall exceeded', () {
    final state = evalUtc(timeline(utc(2026, 6, 10, 6), [
      (ActivityType.driving, 270),
    ]));
    expect(state.counter(CounterType.continuousDriving)!.level,
        ComplianceLevel.exceeded);
    expect(state.overall, ComplianceLevel.exceeded);
    final first = state.upcomingActions.first;
    expect(first.type, RequiredActionType.takeBreak);
    expect(first.timeUntil, Duration.zero);
  });

  test('aggregates violations across counters', () {
    final state = evalUtc(timeline(utc(2026, 6, 10, 6), [
      (ActivityType.driving, 700),
    ]));
    final counters = state.violations.map((v) => v.counter).toSet();
    expect(
      counters,
      containsAll(
          [CounterType.continuousDriving, CounterType.dailyDriving]),
    );
  });

  test('a regular 11h daily rest resets daily driving and the duty window', () {
    final state = evalUtc(timeline(utc(2026, 6, 10, 4), [
      (ActivityType.driving, 540), // 9h driving
      (ActivityType.rest, 660), // 11h regular daily rest
      (ActivityType.driving, 60), // resume: 1h into the new day
    ]));
    expect(state.currentActivity, ActivityType.driving);
    expect(state.counter(CounterType.dailyDriving)!.used, mins(60));
    expect(state.counter(CounterType.dutyWindow)!.used, mins(60));
  });

  group('time zone & midnight', () {
    test('the week boundary is local Monday 00:00 in the base time zone', () {
      final warsaw = tz.getLocation('Europe/Warsaw');
      // Drive Sun 21:00 UTC -> Mon 01:00 UTC. In June, Warsaw is CEST (UTC+2),
      // so local Monday 00:00 == Sun 22:00 UTC. Only the part after that counts
      // toward the new week.
      final tl = timeline(utc(2026, 6, 7, 21), [
        (ActivityType.driving, 240),
      ]);

      final inWarsaw = evalUtc(tl, location: warsaw);
      expect(inWarsaw.counter(CounterType.weeklyDriving)!.used, mins(180));

      final inUtc = evalUtc(tl);
      expect(inUtc.counter(CounterType.weeklyDriving)!.used, mins(60));
    });
  });

  test('crew mode uses the 30h duty window', () {
    final tl = timeline(utc(2026, 6, 9, 0), [
      (ActivityType.rest, 660),
      (ActivityType.driving, 1500), // 25h since the duty start
    ]);
    final solo = evalUtc(tl);
    final crew = engine.evaluate(
      events: tl.events,
      rules: RulesPack.defaultEuPl,
      now: tl.now,
      timeZone: tz.UTC,
      dutyMode: DutyMode.crew,
    );
    expect(
      solo.violations.any((v) => v.counter == CounterType.dutyWindow),
      isTrue,
    );
    expect(
      crew.violations.any((v) => v.counter == CounterType.dutyWindow),
      isFalse,
    );
  });
}
