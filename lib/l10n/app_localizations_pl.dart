// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'E-Tacho';

  @override
  String get onboardingTitle => 'Witaj';

  @override
  String get onboardingIntro =>
      'E-Tacho pomaga pilnować czasu jazdy, przerw i odpoczynków zgodnie z rozporządzeniem 561/2006 i polskim prawem.';

  @override
  String get onboardingConsent =>
      'Zapoznałem(-am) się z powyższym i wyrażam zgodę na przetwarzanie moich danych o czasie pracy zgodnie z polityką prywatności (RODO).';

  @override
  String get onboardingAccept => 'Zaczynaj';

  @override
  String get currentState => 'Aktualny stan';

  @override
  String get stateDriving => 'Jazda';

  @override
  String get stateOtherWork => 'Inna praca';

  @override
  String get stateAvailability => 'Dyspozycyjność';

  @override
  String get stateRest => 'Przerwa / odpoczynek';

  @override
  String get untilBreak => 'Do przerwy';

  @override
  String get untilDutyEnd => 'Do końca doby';

  @override
  String get btnDrive => 'Jazda';

  @override
  String get btnOtherWork => 'Inna praca';

  @override
  String get btnAvailability => 'Dyspozycyjność';

  @override
  String get btnRest => 'Przerwa';

  @override
  String get actionTakeBreak => 'Wymagana przerwa';

  @override
  String get actionTakeWorkBreak => 'Wymagana przerwa od pracy';

  @override
  String get actionTakeDailyRest => 'Wymagany odpoczynek dzienny';

  @override
  String get actionEndDuty => 'Zbliża się koniec doby';

  @override
  String get actionMayResumeWork => 'Możesz wznowić pracę';

  @override
  String actionIn(String label, String time) {
    return '$label za $time';
  }

  @override
  String actionNow(String label) {
    return '$label: teraz';
  }

  @override
  String get historyTitle => 'Historia';

  @override
  String get historyEmpty => 'Brak zarejestrowanej aktywności.';

  @override
  String get noData => 'Brak aktywności — wybierz stan poniżej.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsBuffer => 'Bufor ostrzeżenia';

  @override
  String get settingsTimeZone => 'Strefa bazowa';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get settingsExport => 'Eksport dnia (CSV) do schowka';

  @override
  String get settingsReset => 'Reset danych';

  @override
  String get resetConfirmTitle => 'Zresetować dane?';

  @override
  String get resetConfirmBody => 'To trwale usunie całą zapisaną aktywność.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get reset => 'Resetuj';

  @override
  String get exportCopied => 'Skopiowano do schowka';

  @override
  String get resetDone => 'Dane wyczyszczone';

  @override
  String get notifBreak => 'Czas na 45-minutową przerwę';

  @override
  String get notifDailyDriving => 'Zbliża się dzienny limit jazdy';

  @override
  String get notifDuty => 'Zbliża się koniec doby pracy';

  @override
  String get notifWeeklyDriving => 'Zbliża się tygodniowy limit jazdy';

  @override
  String get notifFortnightly => 'Zbliża się dwutygodniowy limit jazdy';

  @override
  String get notifWorkBreak => 'Należna przerwa od pracy';

  @override
  String get notifResume => 'Możesz wznowić pracę';

  @override
  String get detectDrivingTitle => 'Wykryto jazdę';

  @override
  String detectDrivingBody(String time) {
    return 'Rozpocząć jazdę od $time?';
  }

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get authSignInTitle => 'Logowanie';

  @override
  String get authRegisterTitle => 'Utwórz konto';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Hasło';

  @override
  String get signIn => 'Zaloguj';

  @override
  String get register => 'Zarejestruj';

  @override
  String get signInWithGoogle => 'Kontynuuj z Google';

  @override
  String get signInWithApple => 'Kontynuuj z Apple';

  @override
  String get authToggleToRegister => 'Nie masz konta? Zarejestruj się';

  @override
  String get authToggleToSignIn => 'Masz konto? Zaloguj się';

  @override
  String get authError =>
      'Coś poszło nie tak. Sprawdź dane i spróbuj ponownie.';

  @override
  String get signOut => 'Wyloguj';

  @override
  String get disclaimer =>
      'Narzędzie pomocnicze — nie zastępuje tachografu i nie gwarantuje zgodności z przepisami.';
}
