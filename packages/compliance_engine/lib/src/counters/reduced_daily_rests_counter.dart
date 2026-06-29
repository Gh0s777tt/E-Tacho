import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(6): between two weekly rests, at most three daily rests
/// may be reduced (9h up to but below the 11h regular rest).
///
/// A 3h + 9h *split* daily rest (art. 8(2)) is a REGULAR rest, so the 9h second
/// part must NOT be counted as a reduced rest. We walk the rest periods in order
/// since the last weekly rest, tracking whether a >= 3h first part preceded the
/// 9–11h rest within the same day.
class ReducedDailyRestsCounter implements Counter {
  const ReducedDailyRestsCounter();

  @override
  CounterType get type => CounterType.reducedDailyRests;

  @override
  CounterResult compute(CounterContext ctx) {
    final rules = ctx.rules;
    final timeline = ctx.timeline;
    final anchor = timeline.lastRestEndOfAtLeast(rules.weeklyRestReduced) ??
        (timeline.isEmpty ? ctx.now : timeline.intervals.first.start);

    var count = 0;
    var firstPartSeen = false;
    for (final rest in timeline.restPeriods()) {
      if (rest.start.isBefore(anchor)) continue;
      final end = rest.end.isAfter(ctx.now) ? ctx.now : rest.end;
      final duration = end.difference(rest.start);

      if (duration >= rules.dailyRestRegular) {
        // A regular (or weekly) rest ends the day; never reduced.
        firstPartSeen = false;
      } else if (duration >= rules.dailyRestReduced) {
        // A 9–11h daily rest. It is the second part of a split — and therefore
        // a regular rest, not reduced — if a >= 3h first part preceded it today.
        if (!firstPartSeen) count++;
        firstPartSeen = false;
      } else if (duration >= rules.dailyRestSplitFirst) {
        // Candidate first part of a split rest.
        firstPartSeen = true;
      }
      // Shorter rests are breaks; they neither end the day nor start a split.
    }

    final limit = rules.reducedDailyRestsBetweenWeeklyMax;
    final status =
        CounterStatus.forCount(type: type, count: count, countLimit: limit);

    final violations = <Violation>[];
    if (count > limit) {
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
