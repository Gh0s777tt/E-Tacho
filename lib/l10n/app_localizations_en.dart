// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'E-Tacho';

  @override
  String get currentState => 'Current state';

  @override
  String get stateDriving => 'Driving';

  @override
  String get stateOtherWork => 'Other work';

  @override
  String get stateAvailability => 'Availability';

  @override
  String get stateRest => 'Break / rest';

  @override
  String get untilBreak => 'Until break';

  @override
  String get untilDutyEnd => 'Until end of day';

  @override
  String get btnDrive => 'Drive';

  @override
  String get btnOtherWork => 'Other work';

  @override
  String get btnAvailability => 'Availability';

  @override
  String get btnRest => 'Break';

  @override
  String get actionTakeBreak => 'Break required';

  @override
  String get actionTakeWorkBreak => 'Work break required';

  @override
  String get actionTakeDailyRest => 'Daily rest required';

  @override
  String get actionEndDuty => 'End of day approaching';

  @override
  String get actionMayResumeWork => 'You may resume work';

  @override
  String actionIn(String label, String time) {
    return '$label in $time';
  }

  @override
  String actionNow(String label) {
    return '$label: now';
  }

  @override
  String get noData => 'No activity yet — pick a state below.';

  @override
  String get disclaimer =>
      'A supporting tool only — it does not replace the tachograph and does not guarantee compliance.';
}
