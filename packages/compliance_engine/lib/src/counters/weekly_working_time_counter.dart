import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// Polish Drivers' Working Time Act: weekly working time (driving + other work)
/// must not exceed 60h in a single week. The week is fixed (Monday–Sunday) in
/// the driver's base time zone.
///
/// The 48h *average* over the reference period is a stage-2 feature.
// TODO: zweryfikować z przepisami — uśrednianie 48h w okresie rozliczeniowym (etap 2).
class WeeklyWorkingTimeCounter implements Counter {
  const WeeklyWorkingTimeCounter();

  @override
  CounterType get type => CounterType.weeklyWorkingTime;

  @override
  CounterResult compute(CounterContext ctx) {
    final weekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    final used = ctx.timeline.workingTimeBetween(weekStart, ctx.now);
    final limit = ctx.rules.weeklyWorkingTimeMax;

    final status = CounterStatus.forDuration(
      type: type,
      used: used,
      limit: limit,
      buffer: ctx.buffer,
    );

    final violations = <Violation>[];
    if (used > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.weekly_working_time',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
