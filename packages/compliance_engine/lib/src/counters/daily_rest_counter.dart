import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import 'counter.dart';

/// EU 561/2006 art. 8(2): a regular daily rest is 11h; it may be reduced to 9h
/// (tracked by [CounterType.reducedDailyRests]). While the driver is resting,
/// this reports rest progress and when they may resume work (after the 9h
/// minimum). Resting never contributes a "red" level to the overall state.
class DailyRestCounter implements Counter {
  const DailyRestCounter();

  @override
  CounterType get type => CounterType.dailyRest;

  @override
  CounterResult compute(CounterContext ctx) {
    final regular = ctx.rules.dailyRestRegular;
    final reduced = ctx.rules.dailyRestReduced;
    final isResting = ctx.timeline.currentActivity == ActivityType.rest;
    final since = ctx.timeline.currentActivitySince;
    final restSoFar = isResting && since != null
        ? ctx.now.difference(since)
        : Duration.zero;

    final status = CounterStatus(
      type: type,
      metric: CounterMetric.duration,
      level: ComplianceLevel.ok,
      used: restSoFar,
      limit: regular,
    );

    final actions = <RequiredAction>[];
    if (isResting && since != null) {
      final untilReduced = reduced - restSoFar;
      final due = untilReduced.isNegative ? Duration.zero : untilReduced;
      actions.add(RequiredAction(
        type: RequiredActionType.mayResumeWork,
        timeUntil: due,
        messageKey: due == Duration.zero
            ? 'action.rest.may_resume_now'
            : 'action.rest.may_resume_in',
        messageArgs: {
          'reducedMin': reduced.inMinutes,
          'regularMin': regular.inMinutes,
        },
      ));
    }

    return CounterResult(status: status, actions: actions);
  }
}
