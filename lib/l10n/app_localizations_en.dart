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
  String get onboardingTitle => 'Welcome';

  @override
  String get onboardingIntro =>
      'E-Tacho helps you track driving time, breaks and rest under EU Regulation 561/2006 and Polish law.';

  @override
  String get onboardingConsent =>
      'I have read the above and consent to the processing of my working-time data in line with the privacy policy (GDPR).';

  @override
  String get onboardingAccept => 'Get started';

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
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No activity recorded yet.';

  @override
  String get noData => 'No activity yet — pick a state below.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsBuffer => 'Warning buffer';

  @override
  String get settingsTimeZone => 'Base time zone';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsExport => 'Export day (CSV) to clipboard';

  @override
  String get settingsReset => 'Reset data';

  @override
  String get resetConfirmTitle => 'Reset data?';

  @override
  String get resetConfirmBody =>
      'This permanently deletes all recorded activity.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get exportCopied => 'Copied to clipboard';

  @override
  String get resetDone => 'Data cleared';

  @override
  String get notifBreak => 'Time for a 45-minute break';

  @override
  String get notifDailyDriving => 'Daily driving limit is approaching';

  @override
  String get notifDuty => 'End of your working day is approaching';

  @override
  String get notifWeeklyDriving => 'Weekly driving limit is approaching';

  @override
  String get notifFortnightly => 'Two-week driving limit is approaching';

  @override
  String get notifWorkBreak => 'A work break is due';

  @override
  String get notifResume => 'You may resume work';

  @override
  String get disclaimer =>
      'A supporting tool only — it does not replace the tachograph and does not guarantee compliance.';
}
