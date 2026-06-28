import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// EU 561/2006 art. 6(3): total driving across any two consecutive weeks must
/// not exceed 90h. Weeks are fixed in the driver's base time zone.
class FortnightlyDrivingCounter implements Counter {
  const FortnightlyDrivingCounter();

  @override
  CounterType get type => CounterType.fortnightlyDriving;

  @override
  CounterResult compute(CounterContext ctx) {
    final thisWeekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    // One second before this week's start lands in the previous week.
    final prevWeekStart = startOfIsoWeek(
      thisWeekStart.subtract(const Duration(seconds: 1)),
      ctx.timeZone,
    );
    final used = ctx.timeline.drivingBetween(prevWeekStart, ctx.now);
    final limit = ctx.rules.twoWeeklyDrivingMax;

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
        messageKey: 'violation.fortnightly_driving',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
