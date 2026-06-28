import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

/// Pushes the two key countdowns to the OS home-screen widget. No-op on web.
/// The native widget UI is defined per platform (Android provider; iOS WidgetKit
/// is a later step).
class HomeWidgetService {
  static const String _androidProvider = 'ETachoWidgetProvider';
  static const String _iOSName = 'ETachoWidget';

  Future<void> update({
    required String breakLabel,
    required String breakValue,
    required String dutyLabel,
    required String dutyValue,
  }) async {
    if (kIsWeb) return;
    await HomeWidget.saveWidgetData<String>('break_label', breakLabel);
    await HomeWidget.saveWidgetData<String>('break_value', breakValue);
    await HomeWidget.saveWidgetData<String>('duty_label', dutyLabel);
    await HomeWidget.saveWidgetData<String>('duty_value', dutyValue);
    await HomeWidget.updateWidget(
      androidName: _androidProvider,
      iOSName: _iOSName,
    );
  }
}
