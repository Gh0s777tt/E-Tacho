import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// EU 561/2006 art. 6(2): weekly driving must not exceed 56h. The week is fixed
/// (Monday 00:00 to Sunday 24:00) in the driver's base time zone.
class WeeklyDrivingCounter implements Counter {
  const WeeklyDrivingCounter();

  @override
  CounterType get type => CounterType.weeklyDriving;

  @override
  CounterResult compute(CounterContext ctx) {
    final weekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    final used = ctx.timeline.drivingBetween(weekStart, ctx.now);
    final limit = ctx.rules.weeklyDrivingMax;

    final status = CounterStatus.forDuration(
      type: type,
      used: used,
      limit: limit,
      buffer: ctx.buffer,
      limitReachedAt: ctx.isDrivingNow ? ctx.now.add(limit - used) : null,
    );

    final violations = <Violation>[];
    if (used > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.weekly_driving',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
