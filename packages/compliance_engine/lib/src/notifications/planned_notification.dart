import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A concrete, schedulable local notification with an absolute fire time (UTC).
///
/// Carries i18n keys + args, never pre-formatted text. The [id] is stable per
/// logical alert so the app can diff a fresh plan against what is already
/// pending and cancel/replace accordingly.
@immutable
class PlannedNotification extends Equatable {
  const PlannedNotification({
    required this.id,
    required this.fireAt,
    required this.titleKey,
    required this.bodyKey,
    this.args = const {},
  });

  final String id;
  final DateTime fireAt;
  final String titleKey;
  final String bodyKey;
  final Map<String, Object> args;

  @override
  List<Object?> get props => [id, fireAt, titleKey, bodyKey, args];

  @override
  bool get stringify => true;
}

/// Driver notification settings — the lead times before a limit at which to
/// warn. Defaults to 30 min, 15 min and "now" (the configurable safety buffer
/// from §4.5 maps onto the largest lead time).
@immutable
class NotificationPreferences extends Equatable {
  const NotificationPreferences({
    this.leadTimes = const [
      Duration(minutes: 30),
      Duration(minutes: 15),
      Duration.zero,
    ],
  });

  final List<Duration> leadTimes;

  @override
  List<Object?> get props => [leadTimes];
}
