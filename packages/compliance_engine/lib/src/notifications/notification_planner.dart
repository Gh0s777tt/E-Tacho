import '../models/compliance_state.dart';
import '../models/counter_type.dart';
import '../models/required_action.dart';
import 'planned_notification.dart';

/// Pure projection of a [ComplianceState] into a concrete, cancellable set of
/// local notifications. Recomputed on every state change; the app diffs the
/// result against what `flutter_local_notifications` currently has pending.
///
/// This is what makes offline, pre-scheduled iOS notifications possible: it
/// computes *when* limits will be hit assuming the current activity continues.
class NotificationPlanner {
  const NotificationPlanner();

  List<PlannedNotification> plan({
    required ComplianceState state,
    required DateTime now,
    NotificationPreferences prefs = const NotificationPreferences(),
  }) {
    assert(now.isUtc, 'now must be UTC');
    final result = <PlannedNotification>[];

    state.counters.forEach((type, status) {
      final reachedAt = status.limitReachedAt;
      final keys = _limitKeys[type];
      if (reachedAt == null || keys == null || !reachedAt.isAfter(now)) return;
      for (final lead in prefs.leadTimes) {
        final fireAt = reachedAt.subtract(lead);
        if (!fireAt.isAfter(now)) continue;
        result.add(PlannedNotification(
          id: '${type.name}@${lead.inMinutes}',
          fireAt: fireAt,
          titleKey: keys.title,
          bodyKey: lead == Duration.zero ? keys.bodyNow : keys.bodyLead,
          args: {'leadMin': lead.inMinutes},
        ));
      }
    });

    for (final action in state.upcomingActions) {
      if (action.type == RequiredActionType.mayResumeWork &&
          action.timeUntil > Duration.zero) {
        result.add(PlannedNotification(
          id: 'mayResumeWork',
          fireAt: now.add(action.timeUntil),
          titleKey: 'notif.may_resume_work.title',
          bodyKey: 'notif.may_resume_work.body',
        ));
      }
    }

    result.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    return result;
  }
}

class _Keys {
  const _Keys(this.title, this.bodyLead, this.bodyNow);
  final String title;
  final String bodyLead;
  final String bodyNow;
}

const Map<CounterType, _Keys> _limitKeys = {
  CounterType.continuousDriving:
      _Keys('notif.break.title', 'notif.break.body_lead', 'notif.break.body_now'),
  CounterType.dailyDriving: _Keys('notif.daily_driving.title',
      'notif.daily_driving.body_lead', 'notif.daily_driving.body_now'),
  CounterType.dutyWindow:
      _Keys('notif.duty.title', 'notif.duty.body_lead', 'notif.duty.body_now'),
  CounterType.weeklyDriving: _Keys('notif.weekly_driving.title',
      'notif.weekly_driving.body_lead', 'notif.weekly_driving.body_now'),
  CounterType.fortnightlyDriving: _Keys('notif.fortnightly_driving.title',
      'notif.fortnightly_driving.body_lead', 'notif.fortnightly_driving.body_now'),
  CounterType.workingTimeBreak: _Keys('notif.work_break.title',
      'notif.work_break.body_lead', 'notif.work_break.body_now'),
  CounterType.weeklyRest: _Keys('notif.weekly_rest.title',
      'notif.weekly_rest.body_lead', 'notif.weekly_rest.body_now'),
};
