import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(6): a reduced weekly rest must be compensated by an
/// equivalent block of rest before the end of the third following week. This
/// reports the OUTSTANDING compensation: gross reductions over the recent weeks,
/// netted against any "excess" rest (weekly rests longer than the 45h regular).
/// Informational — it does not raise a violation.
// TODO: zweryfikować — dokładny termin (koniec 3. tygodnia) i wymóg, by
// rekompensata była dołączona en bloc do odpoczynku >= 9h.
class WeeklyRestCompensationCounter implements Counter {
  const WeeklyRestCompensationCounter();

  @override
  CounterType get type => CounterType.weeklyRestCompensation;

  @override
  CounterResult compute(CounterContext ctx) {
    final rules = ctx.rules;
    final thisWeekStart = startOfIsoWeek(ctx.now, ctx.timeZone);
    // Look back roughly three ISO weeks (the compensation horizon).
    final lookbackStart = startOfIsoWeek(
      thisWeekStart.subtract(const Duration(days: 15)),
      ctx.timeZone,
    );

    var owed = Duration.zero;
    var credit = Duration.zero;
    for (final rest
        in ctx.timeline.restsOfAtLeast(rules.weeklyRestReduced, after: lookbackStart)) {
      if (rest.duration < rules.weeklyRestRegular) {
        owed += rules.weeklyRestRegular - rest.duration;
      } else {
        // Rest beyond the regular 45h can serve as compensation.
        credit += rest.duration - rules.weeklyRestRegular;
      }
    }
    final net = owed - credit;
    final outstanding = net.isNegative ? Duration.zero : net;

    return CounterResult(
      status: CounterStatus(
        type: type,
        metric: CounterMetric.duration,
        level: outstanding > Duration.zero
            ? ComplianceLevel.approaching
            : ComplianceLevel.ok,
        used: outstanding,
        limit: Duration.zero,
      ),
    );
  }
}
