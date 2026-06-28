import '../models/activity_event.dart';
import '../models/activity_type.dart';
import 'activity_interval.dart';

/// Normalises a time-ordered stream of [ActivityEvent]s into closed
/// [ActivityInterval]s, and provides the queries the counters need.
///
/// This is where the "state machine" lives: each event starts a state that runs
/// until the next event, and the final event runs until [now]. The timeline is
/// pure and time-zone agnostic (everything is UTC); calendar-boundary maths
/// lives in the counters that need a time zone.
class ActivityTimeline {
  ActivityTimeline._(this.intervals, this.now);

  /// Builds a timeline. Events are copied and sorted; future events (starting
  /// after [now]) are ignored and the open interval is clamped to [now].
  factory ActivityTimeline.fromEvents(
    List<ActivityEvent> events, {
    required DateTime now,
  }) {
    assert(now.isUtc, 'now must be UTC');
    if (events.isEmpty) return ActivityTimeline._(const [], now);

    final sorted = [...events]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final result = <ActivityInterval>[];
    for (var i = 0; i < sorted.length; i++) {
      final start = sorted[i].startTime;
      if (!start.isBefore(now)) continue; // event at/after now → nothing yet
      final rawEnd =
          i + 1 < sorted.length ? sorted[i + 1].startTime : now;
      final end = rawEnd.isAfter(now) ? now : rawEnd;
      if (!end.isAfter(start)) continue; // zero-length, skip
      result.add(ActivityInterval(type: sorted[i].type, start: start, end: end));
    }
    return ActivityTimeline._(List.unmodifiable(result), now);
  }

  /// Contiguous intervals in chronological order (UTC). May be empty.
  final List<ActivityInterval> intervals;

  /// The evaluation instant (UTC).
  final DateTime now;

  bool get isEmpty => intervals.isEmpty;

  ActivityType get currentActivity =>
      intervals.isEmpty ? ActivityType.rest : intervals.last.type;

  /// Start (UTC) of the current contiguous run of [currentActivity], or null if
  /// there are no events.
  DateTime? get currentActivitySince {
    if (intervals.isEmpty) return null;
    final type = intervals.last.type;
    var since = intervals.last.start;
    for (var i = intervals.length - 2; i >= 0; i--) {
      if (intervals[i].type == type) {
        since = intervals[i].start;
      } else {
        break;
      }
    }
    return since;
  }

  /// Total time matching [test] within `[from, to)`.
  Duration durationWhere(
    bool Function(ActivityType type) test, {
    required DateTime from,
    required DateTime to,
  }) {
    var total = Duration.zero;
    for (final iv in intervals) {
      if (test(iv.type)) total += iv.overlap(from, to);
    }
    return total;
  }

  Duration drivingBetween(DateTime from, DateTime to) =>
      durationWhere((t) => t.isDriving, from: from, to: to);

  Duration workingTimeBetween(DateTime from, DateTime to) =>
      durationWhere((t) => t.isWorkingTime, from: from, to: to);

  /// Maximal contiguous runs of [ActivityType.rest], chronologically.
  List<ActivityInterval> restPeriods() {
    final result = <ActivityInterval>[];
    for (final iv in intervals) {
      if (iv.type != ActivityType.rest) continue;
      if (result.isNotEmpty && result.last.end == iv.start) {
        final merged = ActivityInterval(
          type: ActivityType.rest,
          start: result.last.start,
          end: iv.end,
        );
        result[result.length - 1] = merged;
      } else {
        result.add(iv);
      }
    }
    return result;
  }

  /// End (UTC) of the most recent rest period that has accumulated at least
  /// [min] by time [before] (defaults to [now]). An in-progress rest counts
  /// once it reaches [min]. Returns null if no such rest exists.
  DateTime? lastRestEndOfAtLeast(Duration min, {DateTime? before}) {
    final at = before ?? now;
    DateTime? result;
    for (final r in restPeriods()) {
      if (!r.start.isBefore(at)) continue;
      final end = r.end.isAfter(at) ? at : r.end;
      if (end.difference(r.start) >= min) {
        if (result == null || end.isAfter(result)) result = end;
      }
    }
    return result;
  }

  /// Rest periods that reached at least [min] duration and ended within
  /// `(after, before]`. Used to count daily rests between weekly rests.
  List<ActivityInterval> restsOfAtLeast(
    Duration min, {
    required DateTime after,
    DateTime? before,
  }) {
    final at = before ?? now;
    final result = <ActivityInterval>[];
    for (final r in restPeriods()) {
      final end = r.end.isAfter(at) ? at : r.end;
      if (end.isAfter(after) &&
          !end.isAfter(at) &&
          end.difference(r.start) >= min) {
        result.add(r);
      }
    }
    return result;
  }
}
