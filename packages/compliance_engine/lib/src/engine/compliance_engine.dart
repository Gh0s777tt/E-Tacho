import 'package:timezone/timezone.dart' as tz;

import '../counters/continuous_driving_counter.dart';
import '../counters/counter.dart';
import '../counters/daily_driving_counter.dart';
import '../counters/daily_rest_counter.dart';
import '../counters/duty_window_counter.dart';
import '../counters/extended_driving_days_counter.dart';
import '../counters/fortnightly_driving_counter.dart';
import '../counters/night_work_counter.dart';
import '../counters/reduced_daily_rests_counter.dart';
import '../counters/weekly_driving_counter.dart';
import '../counters/weekly_working_time_counter.dart';
import '../models/activity_event.dart';
import '../models/compliance_state.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import '../models/rules_pack.dart';
import '../models/violation.dart';
import '../timeline/activity_timeline.dart';

/// The public entry point of the engine.
///
/// Pure and deterministic: no I/O, timers, Flutter or database access. Given the
/// (windowed) event history, the rules pack, the current instant, the driver's
/// base time zone and their safety buffer, it returns the complete
/// [ComplianceState]. Call it on every UI tick — it is cheap to recompute.
class ComplianceEngine {
  ComplianceEngine({List<Counter>? counters})
      : counters = counters ?? defaultCounters;

  /// The default set — one counter per rule. Pass a custom list to add or swap
  /// rules without touching this class.
  static const List<Counter> defaultCounters = [
    ContinuousDrivingCounter(),
    DailyDrivingCounter(),
    ExtendedDrivingDaysCounter(),
    DutyWindowCounter(),
    DailyRestCounter(),
    ReducedDailyRestsCounter(),
    WeeklyDrivingCounter(),
    FortnightlyDrivingCounter(),
    WeeklyWorkingTimeCounter(),
    NightWorkCounter(),
  ];

  final List<Counter> counters;

  ComplianceState evaluate({
    required List<ActivityEvent> events,
    required RulesPack rules,
    required DateTime now,
    required tz.Location timeZone,
    Duration safetyBuffer = const Duration(minutes: 30),
  }) {
    assert(now.isUtc, 'now must be UTC');

    final timeline = ActivityTimeline.fromEvents(events, now: now);
    final ctx = CounterContext(
      timeline: timeline,
      rules: rules,
      now: now,
      timeZone: timeZone,
      buffer: safetyBuffer,
    );

    final statuses = <CounterType, CounterStatus>{};
    final actions = <RequiredAction>[];
    final violations = <Violation>[];
    var overall = ComplianceLevel.ok;

    for (final counter in counters) {
      final result = counter.compute(ctx);
      statuses[result.status.type] = result.status;
      actions.addAll(result.actions);
      violations.addAll(result.violations);
      overall = overall.orHigher(result.status.level);
    }

    actions.sort((a, b) => a.timeUntil.compareTo(b.timeUntil));

    return ComplianceState(
      evaluatedAt: now,
      currentActivity: timeline.currentActivity,
      currentActivitySince: timeline.currentActivitySince,
      counters: Map.unmodifiable(statuses),
      upcomingActions: List.unmodifiable(actions),
      violations: List.unmodifiable(violations),
      overall: overall,
    );
  }
}
