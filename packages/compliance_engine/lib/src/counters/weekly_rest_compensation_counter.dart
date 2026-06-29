import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(6): a reduced weekly rest must be compensated by an
/// equivalent block of rest before the end of the third following week. This
/// reports the outstanding compensation (gross reductions over the recent
/// weeks) — informational, not a violation.
// TODO: zweryfikować — dokładny termin (koniec 3. tygodnia) oraz odejmowanie już
// odebranej rekompensaty (dołączonej do odpoczynku >= 9h).
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
    for (final rest in ctx.timeline
        .restsOfAtLeast(rules.weeklyRestReduced, after: lookbackStart)
        .where((r) => r.duration < rules.weeklyRestRegular)) {
      owed += rules.weeklyRestRegular - rest.duration;
    }

    return CounterResult(
      status: CounterStatus(
        type: type,
        metric: CounterMetric.duration,
        level: owed > Duration.zero
            ? ComplianceLevel.approaching
            : ComplianceLevel.ok,
        used: owed,
        limit: Duration.zero,
      ),
    );
  }
}
