import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/duty_periods.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// EU 561/2006 art. 6(1): a daily driving period may be extended from 9h to 10h
/// at most twice in a week. This counts how many daily driving periods starting
/// in the current week exceeded 9h.
class ExtendedDrivingDaysCounter implements Counter {
  const ExtendedDrivingDaysCounter();

  @override
  CounterType get type => CounterType.extendedDrivingDays;

  @override
  CounterResult compute(CounterContext ctx) {
    final weekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    final periods = drivingPeriods(ctx.timeline, ctx.rules.dailyRestReduced);
    final extended = periods
        .where((p) =>
            !p.start.isBefore(weekStart) &&
            p.driving > ctx.rules.dailyDrivingMax)
        .length;
    final limit = ctx.rules.extendedDrivingDaysPerWeekMax;

    final status =
        CounterStatus.forCount(type: type, count: extended, countLimit: limit);

    final violations = <Violation>[];
    if (extended > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.extended_driving_days',
        occurredAt: ctx.now,
        messageArgs: {'maxDays': limit},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
