import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../models/activity_type.dart';

/// A closed time interval during which a single [ActivityType] was active.
/// Both [start] and [end] are in UTC and `end >= start`.
@immutable
class ActivityInterval extends Equatable {
  ActivityInterval({
    required this.type,
    required this.start,
    required this.end,
  })  : assert(start.isUtc, 'start must be UTC'),
        assert(end.isUtc, 'end must be UTC'),
        assert(!end.isBefore(start), 'end must be >= start');

  final ActivityType type;
  final DateTime start;
  final DateTime end;

  Duration get duration => end.difference(start);

  /// The portion of this interval that overlaps the half-open window
  /// `[from, to)`.
  Duration overlap(DateTime from, DateTime to) {
    final s = start.isAfter(from) ? start : from;
    final e = end.isBefore(to) ? end : to;
    return e.isAfter(s) ? e.difference(s) : Duration.zero;
  }

  @override
  List<Object?> get props => [type, start, end];

  @override
  bool get stringify => true;
}
