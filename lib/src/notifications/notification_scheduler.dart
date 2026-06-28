import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../ui_labels.dart';
import 'notification_service.dart';

/// Initialises the notification service and keeps the OS schedule in sync with
/// the planned notifications. Place it under [MaterialApp] so localisations are
/// available. It renders [child] unchanged.
class NotificationScheduler extends ConsumerStatefulWidget {
  const NotificationScheduler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationScheduler> createState() =>
      _NotificationSchedulerState();
}

class _NotificationSchedulerState extends ConsumerState<NotificationScheduler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationServiceProvider).init();
      if (mounted) _sync(ref.read(plannedNotificationsProvider));
    });
  }

  void _sync(List<PlannedNotification> planned) {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final items = [
      for (final p in planned)
        ScheduledNotification(
          id: p.id.hashCode & 0x7fffffff,
          fireAt: p.fireAt,
          title: l.appTitle,
          body: notificationBody(l, p.titleKey),
        ),
    ];
    ref.read(notificationServiceProvider).sync(items);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<PlannedNotification>>(
      plannedNotificationsProvider,
      (_, next) => _sync(next),
    );
    return widget.child;
  }
}
