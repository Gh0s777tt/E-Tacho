import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'activity_type.dart';
import 'counter_status.dart';
import 'counter_type.dart';
import 'required_action.dart';
import 'violation.dart';

/// The complete, immutable output of the engine for a single instant.
///
/// Produced by `ComplianceEngine.evaluate(...)`. It is a pure projection of the
/// event history at [evaluatedAt]; the engine holds no internal state.
@immutable
class ComplianceState extends Equatable {
  const ComplianceState({
    required this.evaluatedAt,
    required this.currentActivity,
    required this.currentActivitySince,
    required this.counters,
    required this.upcomingActions,
    required this.violations,
    required this.overall,
  });

  /// An empty state (no events yet) — everything at rest, no counters.
  factory ComplianceState.empty(DateTime evaluatedAt) => ComplianceState(
        evaluatedAt: evaluatedAt,
        currentActivity: ActivityType.rest,
        currentActivitySince: null,
        counters: const {},
        upcomingActions: const [],
        violations: const [],
        overall: ComplianceLevel.ok,
      );

  /// When this snapshot was computed (UTC).
  final DateTime evaluatedAt;

  final ActivityType currentActivity;

  /// When the current activity started (UTC). Null if there are no events.
  final DateTime? currentActivitySince;

  final Map<CounterType, CounterStatus> counters;

  /// Upcoming obligations, soonest first.
  final List<RequiredAction> upcomingActions;

  final List<Violation> violations;

  /// The worst level across all counters — drives the home-screen accent.
  final ComplianceLevel overall;

  CounterStatus? counter(CounterType type) => counters[type];

  @override
  List<Object?> get props => [
        evaluatedAt,
        currentActivity,
        currentActivitySince,
        counters,
        upcomingActions,
        violations,
        overall,
      ];
}
