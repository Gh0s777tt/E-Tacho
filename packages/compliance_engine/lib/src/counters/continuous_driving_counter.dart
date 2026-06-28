import '../models/activity_type.dart';
import '../models/counter_status.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import '../models/violation.dart';
import 'counter.dart';

/// EU 561/2006 art. 7: after 4h30 of driving a 45-minute break is required.
/// The break may be split into a first part of >= 15 min FOLLOWED BY a second
/// part of >= 30 min (order significant). Only `rest` interrupts count as
/// breaks; other work / availability pause but do not reset the clock.
class ContinuousDrivingCounter implements Counter {
  const ContinuousDrivingCounter();

  @override
  CounterType get type => CounterType.continuousDriving;

  @override
  CounterResult compute(CounterContext ctx) {
    final rules = ctx.rules;
    final firstPartMin = rules.breakSplit[0];
    final secondPartMin = rules.breakSplit[1];

    var driving = Duration.zero;
    var firstPartTaken = false;

    for (final iv in ctx.timeline.intervals) {
      if (iv.type == ActivityType.driving) {
        driving += iv.duration;
      } else if (iv.type == ActivityType.rest) {
        final d = iv.duration;
        if (d >= rules.breakRequired) {
          driving = Duration.zero;
          firstPartTaken = false;
        } else if (firstPartTaken && d >= secondPartMin) {
          driving = Duration.zero;
          firstPartTaken = false;
        } else if (d >= firstPartMin) {
          firstPartTaken = true;
        }
      }
      // otherWork / availability: no effect on the continuous-driving clock.
    }

    final limit = rules.continuousDrivingMax;
    final remaining = limit - driving;
    final drivingNow = ctx.isDrivingNow;

    final status = CounterStatus.forDuration(
      type: type,
      used: driving,
      limit: limit,
      buffer: ctx.buffer,
      limitReachedAt: drivingNow ? ctx.now.add(remaining) : null,
    );

    final actions = <RequiredAction>[];
    if (drivingNow) {
      actions.add(RequiredAction(
        type: firstPartTaken
            ? RequiredActionType.takeSplitBreakSecondPart
            : RequiredActionType.takeBreak,
        timeUntil: remaining,
        messageKey: firstPartTaken
            ? 'action.break.split_second_part'
            : 'action.break.required',
        messageArgs: {
          'minutes':
              (firstPartTaken ? secondPartMin : rules.breakRequired).inMinutes,
        },
      ));
    }

    final violations = <Violation>[];
    if (driving > limit) {
      violations.add(Violation(
        counter: type,
        messageKey: 'violation.continuous_driving',
        occurredAt: ctx.now,
        messageArgs: {'limitMin': limit.inMinutes},
      ));
    }

    return CounterResult(status: status, actions: actions, violations: violations);
  }
}
