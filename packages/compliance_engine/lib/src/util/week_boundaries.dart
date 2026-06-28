import 'package:timezone/timezone.dart' as tz;

/// Calendar-boundary helpers computed in a fixed *base* time zone (the driver's
/// home zone, per the project decision), with DST handled by `package:timezone`.
///
/// All inputs and outputs are UTC [DateTime]s; the [tz.Location] only defines
/// where the local day/week boundaries fall.

/// Start (UTC) of the local day containing [instantUtc].
DateTime startOfLocalDay(DateTime instantUtc, tz.Location loc) {
  final local = tz.TZDateTime.from(instantUtc, loc);
  return tz.TZDateTime(loc, local.year, local.month, local.day).toUtc();
}

/// Start (UTC) of the ISO week (Monday 00:00 local) containing [instantUtc].
DateTime startOfIsoWeek(DateTime instantUtc, tz.Location loc) {
  final local = tz.TZDateTime.from(instantUtc, loc);
  // weekday: Monday = 1 ... Sunday = 7.
  final daysSinceMonday = local.weekday - DateTime.monday;
  return tz.TZDateTime(loc, local.year, local.month, local.day - daysSinceMonday)
      .toUtc();
}

/// Start (UTC) of the ISO week AFTER the one containing [instantUtc] — i.e. the
/// exclusive end of the current week.
DateTime startOfNextIsoWeek(DateTime instantUtc, tz.Location loc) {
  final weekStart = startOfIsoWeek(instantUtc, loc);
  final local = tz.TZDateTime.from(weekStart, loc);
  return tz.TZDateTime(loc, local.year, local.month, local.day + 7).toUtc();
}

/// The night window `[start, end)` (UTC) for the local day containing
/// [instantUtc], given offsets [nightStart]/[nightEnd] from local midnight.
({DateTime start, DateTime end}) nightWindowForDay(
  DateTime instantUtc,
  tz.Location loc, {
  required Duration nightStart,
  required Duration nightEnd,
}) {
  final midnight = startOfLocalDay(instantUtc, loc);
  return (start: midnight.add(nightStart), end: midnight.add(nightEnd));
}
