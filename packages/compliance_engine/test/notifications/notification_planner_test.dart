import 'package:compliance_engine/compliance_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/timezone.dart' as tz;

import '../support/builder.dart';

void main() {
  const planner = NotificationPlanner();
  final engine = ComplianceEngine();

  ComplianceState stateFor(({List<ActivityEvent> events, DateTime now}) tl) =>
      engine.evaluate(
        events: tl.events,
        rules: RulesPack.defaultEuPl,
        now: tl.now,
        timeZone: tz.UTC,
      );

  test('schedules lead-time break alerts while driving', () {
    final tl = timeline(utc(2026, 6, 10, 6), [(ActivityType.driving, 240)]);
    final now = tl.now;
    final plan = planner.plan(state: stateFor(tl), now: now);

    // Continuous-driving limit (270) is 30 min away: 30-min lead lands now
    // (skipped), 15-min lead at +15, "now" lead at +30.
    expect(
      plan.where((n) => n.id == 'continuousDriving@15').single.fireAt,
      now.add(mins(15)),
    );
    expect(
      plan.where((n) => n.id == 'continuousDriving@0').single.fireAt,
      now.add(mins(30)),
    );
    expect(plan.where((n) => n.id == 'continuousDriving@30'), isEmpty);
  });

  test('every notification is in the future and the plan is sorted', () {
    final tl = timeline(utc(2026, 6, 10, 6), [(ActivityType.driving, 240)]);
    final now = tl.now;
    final plan = planner.plan(state: stateFor(tl), now: now);

    expect(plan, isNotEmpty);
    expect(plan.every((n) => n.fireAt.isAfter(now)), isTrue);
    for (var i = 1; i < plan.length; i++) {
      expect(plan[i - 1].fireAt.isAfter(plan[i].fireAt), isFalse);
    }
  });

  test('schedules a may-resume-work alert while resting', () {
    final tl = timeline(utc(2026, 6, 10, 6), [
      (ActivityType.driving, 60),
      (ActivityType.rest, 300), // 5h rest -> may resume after the 9h minimum
    ]);
    final now = tl.now;
    final plan = planner.plan(state: stateFor(tl), now: now);

    final resume = plan.where((n) => n.id == 'mayResumeWork').single;
    expect(resume.fireAt, now.add(mins(240))); // 540 - 300
    // Not driving, so there is no continuous-driving alert.
    expect(plan.where((n) => n.id.startsWith('continuousDriving')), isEmpty);
  });

  test('no alerts with an empty history', () {
    final plan = planner.plan(
      state: ComplianceState.empty(utc(2026, 6, 10, 6)),
      now: utc(2026, 6, 10, 6),
    );
    expect(plan, isEmpty);
  });
}
