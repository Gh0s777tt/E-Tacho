import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import '../models/violation.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(6): a new weekly rest must START within six 24-hour
/// periods (144h) from the end of the previous weekly rest. Mirrors the duty
/// window at the weekly scale.
// TODO: zweryfikować interpretację okna 6x24h (rozpoczęcie vs zakończenie).
class WeeklyRestCounter implements Counter {
  const WeeklyRestCounter();

  @override
  CounterType get type => CounterType.weeklyRest;

  @override
  CounterResult compute(CounterContext ctx) {
    final timeline = ctx.timeline;
    final anchor = timeline.lastRestEndOfAtLeast(ctx.rules.weeklyRestReduced) ??
        (timeline.isEmpty ? ctx.now : timeline.intervals.first.start);
    final limit = ctx.rules.weeklyRestWindow;
    final used = ctx.now.difference(anchor);
    final windowEnd = anchor.add(limit);

    final status = CounterStatus.forDuration(
      type: type,
      used: used,
      limit: limit,
      buffer: ctx.buffer,
      limitReachedAt: windowEnd,
    );

    final actions = <RequiredAction>[];
    final violations = <Violation>[];
    final isResting = timeline.currentActivity == ActivityType.rest;

    if (!isResting) {
      actions.add(RequiredAction(
        type: RequiredActionType.takeWeeklyRest,
        timeUntil: limit - used,
        messageKey: 'action.weekly_rest.required',
        messageArgs: {'limitMin': limit.inMinutes},
      ));
      if (used > limit) violations.add(_violation(ctx, limit));
    } else {
      final since = timeline.currentActivitySince;
      final startedInTime = since != null && !since.isAfter(windowEnd);
      if (!startedInTime && used > limit) {
        violations.add(_violation(ctx, limit));
      }
    }

    return CounterResult(status: status, actions: actions, violations: violations);
  }

  Violation _violation(CounterContext ctx, Duration limit) => Violation(
        counter: type,
        messageKey: 'violation.weekly_rest',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      );
}
