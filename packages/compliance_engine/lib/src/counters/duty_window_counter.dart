import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import '../models/violation.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(2): within 24h of the end of the previous daily/weekly
/// rest, a new daily rest must be taken. This tracks the elapsed time in that
/// window (solo). Crew mode (30h) is stage 2.
///
/// A violation is raised only when the driver is still working past the window,
/// or is resting but only started that rest after the window had already
/// closed.
// TODO: zweryfikować interpretację — "rozpoczęcie" vs "zakończenie" odpoczynku w oknie 24h.
class DutyWindowCounter implements Counter {
  const DutyWindowCounter();

  @override
  CounterType get type => CounterType.dutyWindow;

  @override
  CounterResult compute(CounterContext ctx) {
    final start = ctx.dutyStart;
    final limit = ctx.rules.dutyWindowSolo;
    final used = ctx.now.difference(start);
    final windowEnd = start.add(limit);

    final status = CounterStatus.forDuration(
      type: type,
      used: used,
      limit: limit,
      buffer: ctx.buffer,
      limitReachedAt: windowEnd,
    );

    final actions = <RequiredAction>[];
    final violations = <Violation>[];
    final timeline = ctx.timeline;
    final isResting = timeline.currentActivity == ActivityType.rest;

    if (!isResting) {
      actions.add(RequiredAction(
        type: RequiredActionType.endDuty,
        timeUntil: limit - used,
        messageKey: 'action.duty.end',
        messageArgs: {'limitMin': limit.inMinutes},
      ));
      if (used > limit) {
        violations.add(_violation(ctx, limit));
      }
    } else {
      final restStarted = timeline.currentActivitySince;
      final startedInTime =
          restStarted != null && !restStarted.isAfter(windowEnd);
      if (!startedInTime && used > limit) {
        violations.add(_violation(ctx, limit));
      }
    }

    return CounterResult(status: status, actions: actions, violations: violations);
  }

  Violation _violation(CounterContext ctx, Duration limit) => Violation(
        counter: type,
        messageKey: 'violation.duty_window',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      );
}
