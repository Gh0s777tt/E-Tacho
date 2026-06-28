import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/violation.dart';
import '../util/week_boundaries.dart';
import 'counter.dart';

/// Polish Drivers' Working Time Act: when any work is performed during the night
/// window, working time within the duty period must not exceed 10h.
///
/// "Night" is a configurable window within 00:00–07:00 (the exact span must be
/// verified — the employer sets a 4h period).
// TODO: zweryfikować z przepisami — dokładne okno pory nocnej.
class NightWorkCounter implements Counter {
  const NightWorkCounter();

  @override
  CounterType get type => CounterType.nightWork;

  @override
  CounterResult compute(CounterContext ctx) {
    final start = ctx.dutyStart;
    final used = ctx.timeline.workingTimeBetween(start, ctx.now);
    final limit = ctx.rules.nightWorkMaxPerDuty;

    final performed = _nightWorkPerformed(ctx, start);

    if (!performed) {
      // The 10h cap does not apply; report informational status only.
      return CounterResult(
        status: CounterStatus(
          type: type,
          metric: CounterMetric.duration,
          level: ComplianceLevel.ok,
          used: used,
          limit: limit,
        ),
      );
    }

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
        messageKey: 'violation.night_work',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      ));
    }

    return CounterResult(status: status, violations: violations);
  }

  bool _nightWorkPerformed(CounterContext ctx, DateTime dutyStart) {
    var day = startOfLocalDay(dutyStart, ctx.timeZone);
    while (day.isBefore(ctx.now)) {
      final window = nightWindowForDay(
        day,
        ctx.timeZone,
        nightStart: ctx.rules.nightWindowStart,
        nightEnd: ctx.rules.nightWindowEnd,
      );
      final from = window.start.isAfter(dutyStart) ? window.start : dutyStart;
      final to = window.end.isBefore(ctx.now) ? window.end : ctx.now;
      if (to.isAfter(from)) {
        final work = ctx.timeline
            .durationWhere((t) => t.isWorkingTime, from: from, to: to);
        if (work > Duration.zero) return true;
      }
      day = startOfLocalDay(day.add(const Duration(days: 1)), ctx.timeZone);
    }
    return false;
  }
}
