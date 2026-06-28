import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import 'counter.dart';

/// EU 561/2006 art. 6(1): daily driving must not exceed 9h, extendable to 10h
/// at most twice a week (the extension allowance is tracked by
/// [CounterType.extendedDrivingDays]).
///
/// This counter reports driving since the last daily rest against the 9h limit,
/// and raises a hard violation only above the 10h absolute ceiling. Whether a
/// 9–10h "extended day" is permitted is decided by the extended-days counter.
class DailyDrivingCounter implements Counter {
  const DailyDrivingCounter();

  @override
  CounterType get type => CounterType.dailyDriving;

  @override
  CounterResult compute(CounterContext ctx) {
    final start = ctx.dutyStart;
    final used = ctx.timeline.drivingBetween(start, ctx.now);
    final limit = ctx.rules.dailyDrivingMax;
    final ceiling = ctx.rules.dailyDrivingExtended;

    final status = CounterStatus.forDuration(
      type: type,
      used: used,
      limit: limit,
      buffer: ctx.buffer,
      limitReachedAt: ctx.isDrivingNow ? ctx.now.add(limit - used) : null,
    );

    final violations = <Violation>[];
    if (used > ceiling) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.daily_driving',
        occurredAt: ctx.now,
        messageArgs: {'ceilingMin': ceiling.inMinutes},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
