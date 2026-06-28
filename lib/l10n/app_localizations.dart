import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Tacho'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingTitle;

  /// No description provided for @onboardingIntro.
  ///
  /// In en, this message translates to:
  /// **'E-Tacho helps you track driving time, breaks and rest under EU Regulation 561/2006 and Polish law.'**
  String get onboardingIntro;

  /// No description provided for @onboardingConsent.
  ///
  /// In en, this message translates to:
  /// **'I have read the above and consent to the processing of my working-time data in line with the privacy policy (GDPR).'**
  String get onboardingConsent;

  /// No description provided for @onboardingAccept.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingAccept;

  /// No description provided for @currentState.
  ///
  /// In en, this message translates to:
  /// **'Current state'**
  String get currentState;

  /// No description provided for @stateDriving.
  ///
  /// In en, this message translates to:
  /// **'Driving'**
  String get stateDriving;

  /// No description provided for @stateOtherWork.
  ///
  /// In en, this message translates to:
  /// **'Other work'**
  String get stateOtherWork;

  /// No description provided for @stateAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get stateAvailability;

  /// No description provided for @stateRest.
  ///
  /// In en, this message translates to:
  /// **'Break / rest'**
  String get stateRest;

  /// No description provided for @untilBreak.
  ///
  /// In en, this message translates to:
  /// **'Until break'**
  String get untilBreak;

  /// No description provided for @untilDutyEnd.
  ///
  /// In en, this message translates to:
  /// **'Until end of day'**
  String get untilDutyEnd;

  /// No description provided for @btnDrive.
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get btnDrive;

  /// No description provided for @btnOtherWork.
  ///
  /// In en, this message translates to:
  /// **'Other work'**
  String get btnOtherWork;

  /// No description provided for @btnAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get btnAvailability;

  /// No description provided for @btnRest.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get btnRest;

  /// No description provided for @actionTakeBreak.
  ///
  /// In en, this message translates to:
  /// **'Break required'**
  String get actionTakeBreak;

  /// No description provided for @actionTakeWorkBreak.
  ///
  /// In en, this message translates to:
  /// **'Work break required'**
  String get actionTakeWorkBreak;

  /// No description provided for @actionTakeDailyRest.
  ///
  /// In en, this message translates to:
  /// **'Daily rest required'**
  String get actionTakeDailyRest;

  /// No description provided for @actionEndDuty.
  ///
  /// In en, this message translates to:
  /// **'End of day approaching'**
  String get actionEndDuty;

  /// No description provided for @actionMayResumeWork.
  ///
  /// In en, this message translates to:
  /// **'You may resume work'**
  String get actionMayResumeWork;

  /// No description provided for @actionIn.
  ///
  /// In en, this message translates to:
  /// **'{label} in {time}'**
  String actionIn(String label, String time);

  /// No description provided for @actionNow.
  ///
  /// In en, this message translates to:
  /// **'{label}: now'**
  String actionNow(String label);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No activity recorded yet.'**
  String get historyEmpty;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No activity yet — pick a state below.'**
  String get noData;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsBuffer.
  ///
  /// In en, this message translates to:
  /// **'Warning buffer'**
  String get settingsBuffer;

  /// No description provided for @settingsTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Base time zone'**
  String get settingsTimeZone;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export day (CSV) to clipboard'**
  String get settingsExport;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset data'**
  String get settingsReset;

  /// No description provided for @resetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset data?'**
  String get resetConfirmTitle;

  /// No description provided for @resetConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes all recorded activity.'**
  String get resetConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @exportCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get exportCopied;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Data cleared'**
  String get resetDone;

  /// No description provided for @notifBreak.
  ///
  /// In en, this message translates to:
  /// **'Time for a 45-minute break'**
  String get notifBreak;

  /// No description provided for @notifDailyDriving.
  ///
  /// In en, this message translates to:
  /// **'Daily driving limit is approaching'**
  String get notifDailyDriving;

  /// No description provided for @notifDuty.
  ///
  /// In en, this message translates to:
  /// **'End of your working day is approaching'**
  String get notifDuty;

  /// No description provided for @notifWeeklyDriving.
  ///
  /// In en, this message translates to:
  /// **'Weekly driving limit is approaching'**
  String get notifWeeklyDriving;

  /// No description provided for @notifFortnightly.
  ///
  /// In en, this message translates to:
  /// **'Two-week driving limit is approaching'**
  String get notifFortnightly;

  /// No description provided for @notifWorkBreak.
  ///
  /// In en, this message translates to:
  /// **'A work break is due'**
  String get notifWorkBreak;

  /// No description provided for @notifResume.
  ///
  /// In en, this message translates to:
  /// **'You may resume work'**
  String get notifResume;

  /// No description provided for @detectDrivingTitle.
  ///
  /// In en, this message translates to:
  /// **'Driving detected'**
  String get detectDrivingTitle;

  /// No description provided for @detectDrivingBody.
  ///
  /// In en, this message translates to:
  /// **'Start driving from {time}?'**
  String detectDrivingBody(String time);

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'A supporting tool only — it does not replace the tachograph and does not guarantee compliance.'**
  String get disclaimer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
