import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'activity_type.dart';

/// A single, time-ordered activity change.
///
/// An event marks the START of a state that continues until the [startTime] of
/// the next event. The last event represents the current, open-ended state.
///
/// [startTime] is ALWAYS in UTC. The driver's wall-clock time zone is applied
/// separately (when computing calendar boundaries such as the working week).
@immutable
class ActivityEvent extends Equatable {
  ActivityEvent({
    required this.id,
    required this.type,
    required this.startTime,
    this.source = ActivitySource.manual,
  }) : assert(startTime.isUtc, 'ActivityEvent.startTime must be in UTC');

  final String id;
  final ActivityType type;
  final DateTime startTime;
  final ActivitySource source;

  ActivityEvent copyWith({
    String? id,
    ActivityType? type,
    DateTime? startTime,
    ActivitySource? source,
  }) {
    return ActivityEvent(
      id: id ?? this.id,
      type: type ?? this.type,
      startTime: startTime ?? this.startTime,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [id, type, startTime, source];

  @override
  bool get stringify => true;
}
