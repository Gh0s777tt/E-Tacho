import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'counter_type.dart';

/// Whether a counter measures elapsed time or a discrete count.
enum CounterMetric { duration, count }

/// The computed status of a single counter at a given instant.
///
/// Most counters are [CounterMetric.duration] (e.g. driving time vs a limit).
/// A few are [CounterMetric.count] (e.g. number of extended driving days used).
@immutable
class CounterStatus extends Equatable {
  const CounterStatus({
    required this.type,
    required this.metric,
    required this.level,
    this.used,
    this.limit,
    this.count,
    this.countLimit,
    this.limitReachedAt,
  });

  /// Builds a duration-based status, deriving [level] from the remaining time
  /// and the driver's [buffer].
  factory CounterStatus.forDuration({
    required CounterType type,
    required Duration used,
    required Duration limit,
    required Duration buffer,
    DateTime? limitReachedAt,
  }) {
    final remaining = limit - used;
    final ComplianceLevel level;
    if (remaining <= Duration.zero) {
      level = ComplianceLevel.exceeded;
    } else if (remaining <= buffer) {
      level = ComplianceLevel.critical;
    } else if (remaining <= buffer * 2) {
      level = ComplianceLevel.approaching;
    } else {
      level = ComplianceLevel.ok;
    }
    return CounterStatus(
      type: type,
      metric: CounterMetric.duration,
      level: level,
      used: used,
      limit: limit,
      limitReachedAt: limitReachedAt,
    );
  }

  /// Builds a count-based status (e.g. extended driving days used this week).
  factory CounterStatus.forCount({
    required CounterType type,
    required int count,
    required int countLimit,
  }) {
    final ComplianceLevel level;
    if (count > countLimit) {
      level = ComplianceLevel.exceeded;
    } else if (count >= countLimit) {
      level = ComplianceLevel.critical;
    } else if (count == countLimit - 1 && count > 0) {
      level = ComplianceLevel.approaching;
    } else {
      level = ComplianceLevel.ok;
    }
    return CounterStatus(
      type: type,
      metric: CounterMetric.count,
      level: level,
      count: count,
      countLimit: countLimit,
    );
  }

  final CounterType type;
  final CounterMetric metric;
  final ComplianceLevel level;

  /// Set for [CounterMetric.duration].
  final Duration? used;
  final Duration? limit;

  /// Set for [CounterMetric.count].
  final int? count;
  final int? countLimit;

  /// Projected instant the limit is reached if the current activity continues.
  /// Null when not applicable (e.g. not currently driving, or count-based).
  final DateTime? limitReachedAt;

  /// Remaining time for duration counters (clamped to zero). Zero otherwise.
  Duration get remaining {
    final u = used, l = limit;
    if (u == null || l == null) return Duration.zero;
    final r = l - u;
    return r.isNegative ? Duration.zero : r;
  }

  bool get isExceeded => level == ComplianceLevel.exceeded;

  @override
  List<Object?> get props => [
        type,
        metric,
        level,
        used,
        limit,
        count,
        countLimit,
        limitReachedAt,
      ];

  @override
  bool get stringify => true;
}
