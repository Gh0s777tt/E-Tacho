import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import '../models/violation.dart';
import 'counter.dart';

/// Polish Drivers' Working Time Act art. 13: after 6 consecutive hours of work a
/// break is due — at least 30 min if total daily work is 9h or less, otherwise
/// at least 45 min. The break may be split into parts of at least 15 min.
///
/// Breaks taken under EU 561/2006 art. 7 count toward this requirement: any
/// `rest` interval accrues against the required break and resets the work clock
/// once the requirement is met, so the two break rules are not double-counted.
///
/// Working time = driving + other work; availability and sub-15-min rests
/// neither accrue toward the break nor reset the clock.
// TODO: zweryfikować z przepisami — interpretacja "6 kolejnych godzin", podstawa
// progu 30/45 (czas pracy w dobie) oraz zasada kumulacji części przerwy.
class WorkingTimeBreakCounter implements Counter {
  const WorkingTimeBreakCounter();

  @override
  CounterType get type => CounterType.workingTimeBreak;

  @override
  CounterResult compute(CounterContext ctx) {
    final rules = ctx.rules;
    final dailyWork = ctx.timeline.workingTimeBetween(ctx.dutyStart, ctx.now);
    final required = dailyWork > rules.workBreakLongThresholdWork
        ? rules.workBreakLong
        : rules.workBreakShort;

    var work = Duration.zero;
    var breakAccrued = Duration.zero;
    for (final iv in ctx.timeline.intervals) {
      if (iv.type.isWorkingTime) {
        work += iv.duration;
      } else if (iv.type == ActivityType.rest &&
          iv.duration >= rules.workBreakMinPart) {
        breakAccrued += iv.duration;
        if (breakAccrued >= required) {
          work = Duration.zero;
          breakAccrued = Duration.zero;
        }
      }
    }

    final limit = rules.workBreakAfterWork;
    final remaining = limit - work;
    final working = ctx.timeline.currentActivity.isWorkingTime;

    final status = CounterStatus.forDuration(
      type: type,
      used: work,
      limit: limit,
      buffer: ctx.buffer,
      limitReachedAt: working ? ctx.now.add(remaining) : null,
    );

    final actions = <RequiredAction>[];
    if (working) {
      actions.add(RequiredAction(
        type: RequiredActionType.takeWorkBreak,
        timeUntil: remaining,
        messageKey: 'action.work_break.required',
        messageArgs: {'minutes': required.inMinutes},
      ));
    }

    final violations = <Violation>[];
    if (work > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.work_break',
        occurredAt: ctx.now,
        messageArgs: {'requiredMin': required.inMinutes},
      ));
    }

    return CounterResult(status: status, actions: actions, violations: violations);
  }
}
