import 'package:timezone/timezone.dart' as tz;

import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import '../models/rules_pack.dart';
import '../models/violation.dart';
import '../timeline/activity_timeline.dart';

/// Immutable inputs shared by every counter for a single evaluation.
class CounterContext {
  CounterContext({
    required this.timeline,
    required this.rules,
    required this.now,
    required this.timeZone,
    required this.buffer,
  }) : assert(now.isUtc, 'now must be UTC');

  final ActivityTimeline timeline;
  final RulesPack rules;
  final DateTime now;
  final tz.Location timeZone;

  /// The driver's safety buffer (how early they want to be warned).
  final Duration buffer;

  /// Anchor for the current daily driving period and duty window: the end of
  /// the last daily/weekly rest, falling back to the start of recorded history.
  DateTime get dutyStart {
    final lastRest = timeline.lastRestEndOfAtLeast(rules.dailyRestReduced);
    if (lastRest != null) return lastRest;
    return timeline.isEmpty ? now : timeline.intervals.first.start;
  }

  bool get isDrivingNow => timeline.currentActivity.isDriving;
}

/// A counter's contribution to the overall [ComplianceState].
class CounterResult {
  const CounterResult({
    required this.status,
    this.actions = const [],
    this.violations = const [],
  });

  final CounterStatus status;
  final List<RequiredAction> actions;
  final List<Violation> violations;
}

/// One rule == one counter. Each is pure and independently unit-tested
/// (happy-path + violation), per the engine test spec (§6.4).
abstract interface class Counter {
  CounterType get type;
  CounterResult compute(CounterContext ctx);
}
