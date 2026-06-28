import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(6): between two weekly rests, at most three daily rests
/// may be reduced (9h up to but below the 11h regular rest). This counts the
/// reduced daily rests taken since the last weekly rest.
class ReducedDailyRestsCounter implements Counter {
  const ReducedDailyRestsCounter();

  @override
  CounterType get type => CounterType.reducedDailyRests;

  @override
  CounterResult compute(CounterContext ctx) {
    final t = ctx.timeline;
    final anchor = t.lastRestEndOfAtLeast(ctx.rules.weeklyRestReduced) ??
        (t.isEmpty ? ctx.now : t.intervals.first.start);

    final reduced = t
        .restsOfAtLeast(ctx.rules.dailyRestReduced, after: anchor)
        .where((r) => r.duration < ctx.rules.dailyRestRegular)
        .length;
    final limit = ctx.rules.reducedDailyRestsBetweenWeeklyMax;

    final status =
        CounterStatus.forCount(type: type, count: reduced, countLimit: limit);

    final violations = <Violation>[];
    if (reduced > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.reduced_daily_rests',
        occurredAt: ctx.now,
        messageArgs: {'maxRests': limit},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }
}
