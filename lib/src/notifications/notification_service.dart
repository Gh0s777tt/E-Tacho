import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// A resolved, schedulable notification (i18n already applied).
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime fireAt;
  final String title;
  final String body;
}

/// Thin wrapper over flutter_local_notifications. On web it is a no-op (web
/// preview only); on Android/iOS it schedules pre-computed local alerts so they
/// fire offline. Delivery must be verified on a real device.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (kIsWeb) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings: settings);
    _ready = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Cancels everything and re-schedules the given set (small, so a full
  /// replace is simplest and correct).
  Future<void> sync(List<ScheduledNotification> items) async {
    if (kIsWeb || !_ready) return;
    await _plugin.cancelAll();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'etacho_alerts',
        'E-Tacho alerts',
        channelDescription: 'Driving-time alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (final n in items) {
      await _plugin.zonedSchedule(
        id: n.id,
        title: n.title,
        body: n.body,
        scheduledDate: tz.TZDateTime.from(n.fireAt, tz.UTC),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }
}
