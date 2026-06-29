import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// Polish Drivers' Working Time Act art. 12: average weekly working time over
/// the reference period must not exceed 48h. Modelled as a cap on total working
/// time across the last [RulesPack.referencePeriodWeeks] ISO weeks (rolling):
/// total <= average × weeks.
// TODO: zweryfikować — stały vs kroczący okres, 4 vs 6 miesięcy.
class AverageWeeklyWorkingTimeCounter implements Counter {
  const AverageWeeklyWorkingTimeCounter();

  @override
  CounterType get type => CounterType.averageWeeklyWorkingTime;

  @override
  CounterResult compute(CounterContext ctx) {
    final rules = ctx.rules;
    final weeks = rules.referencePeriodWeeks;
    final thisWeekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    final periodStart = startOfIsoWeek(
      thisWeekStart.subtract(Duration(days: 7 * (weeks - 1))),
      ctx.timeZone,
    );
    final used = ctx.timeline.workingTimeBetween(periodStart, ctx.now);
    final limit = rules.weeklyWorkingTimeAverage * weeks;

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
        messageKey: 'violation.average_weekly_working_time',
        occurredAt: ctx.now,
        messageArgs: {'averageMin': rules.weeklyWorkingTimeAverage.inMinutes},
      ));
    }
    return CounterResult(status: status, violations: violations);
  }
}
