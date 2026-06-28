import 'package:compliance_engine/compliance_engine.dart';
import 'package:compliance_engine/src/counters/counter.dart';
import 'package:timezone/timezone.dart' as tz;

/// A timeline segment: `(activity, durationInMinutes)`.
typedef Segment = (ActivityType, int);

/// Builds a contiguous event stream from [start], one event per segment.
/// `now` is the end of the last segment, so the last segment's duration is how
/// long the current activity has been running.
({List<ActivityEvent> events, DateTime now}) timeline(
  DateTime start,
  List<Segment> segments,
) {
  final events = <ActivityEvent>[];
  var t = start;
  var i = 0;
  for (final (type, minutes) in segments) {
    events.add(ActivityEvent(id: 'e${i++}', type: type, startTime: t));
    t = t.add(Duration(minutes: minutes));
  }
  return (events: events, now: t);
}

/// Builds a [CounterContext] from a [timeline] result.
CounterContext context(
  ({List<ActivityEvent> events, DateTime now}) tl, {
  RulesPack? rules,
  tz.Location? location,
  Duration buffer = const Duration(minutes: 30),
}) {
  return CounterContext(
    timeline: ActivityTimeline.fromEvents(tl.events, now: tl.now),
    rules: rules ?? RulesPack.defaultEuPl,
    now: tl.now,
    timeZone: location ?? tz.UTC,
    buffer: buffer,
  );
}

DateTime utc(int y, int mo, int d, [int h = 0, int mi = 0]) =>
    DateTime.utc(y, mo, d, h, mi);

Duration mins(int m) => Duration(minutes: m);
