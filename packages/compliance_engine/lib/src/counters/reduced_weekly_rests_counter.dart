import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(6): at most one reduced weekly rest (24h up to but below
/// the 45h regular weekly rest) in any two consecutive weeks.
class ReducedWeeklyRestsCounter implements Counter {
  const ReducedWeeklyRestsCounter();

  @override
  CounterType get type => CounterType.reducedWeeklyRests;

  @override
  CounterResult compute(CounterContext ctx) {
    final rules = ctx.rules;
    final thisWeekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    final prevWeekStart = startOfIsoWeek(
      thisWeekStart.subtract(const Duration(seconds: 1)),
      ctx.timeZone,
    );
    final count = ctx.timeline
        .restsOfAtLeast(rules.weeklyRestReduced, after: prevWeekStart)
        .where((r) => r.duration < rules.weeklyRestRegular)
        .length;
    final limit = rules.reducedWeeklyRestsPerFortnightMax;

    final status =
        CounterStatus.forCount(type: type, count: count, countLimit: limit);

    final violations = <Violation>[];
    if (count > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.reduced_weekly_rests',
        occurredAt: ctx.now,
        messageArgs: {'maxRests': limit},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
