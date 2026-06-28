import '../timeline/activity_timeline.dart';

/// A single daily driving period (between two daily rests) and its driving
/// total.
class DrivingPeriod {
  const DrivingPeriod({
    required this.start,
    required this.end,
    required this.driving,
  });

  final DateTime start;
  final DateTime end;
  final Duration driving;
}

/// Segments [t] into daily driving periods separated by daily rests
/// (rest periods of at least [dailyRestMin]). The final, possibly-open period
/// runs to `t.now`.
List<DrivingPeriod> drivingPeriods(ActivityTimeline t, Duration dailyRestMin) {
  if (t.isEmpty) return const [];
  final dailyRests =
      t.restPeriods().where((r) => r.duration >= dailyRestMin).toList();

  final periods = <DrivingPeriod>[];
  var cursor = t.intervals.first.start;
  for (final rest in dailyRests) {
    if (rest.start.isAfter(cursor)) {
      periods.add(DrivingPeriod(
        start: cursor,
        end: rest.start,
        driving: t.drivingBetween(cursor, rest.start),
      ));
    }
    if (rest.end.isAfter(cursor)) cursor = rest.end;
  }
  if (t.now.isAfter(cursor)) {
    periods.add(DrivingPeriod(
      start: cursor,
      end: t.now,
      driving: t.drivingBetween(cursor, t.now),
    ));
  }
  return periods;
}
