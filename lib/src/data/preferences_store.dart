import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value settings (consent flag for now; buffer/locale/tz later).
abstract class PreferencesStore {
  bool get onboardingAccepted;
  Future<void> setOnboardingAccepted(bool value);
}

class SharedPreferencesStore implements PreferencesStore {
  SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;
  static const String _onboardingKey = 'onboarding_accepted';

  @override
  bool get onboardingAccepted => _prefs.getBool(_onboardingKey) ?? false;

  @override
  Future<void> setOnboardingAccepted(bool value) =>
      _prefs.setBool(_onboardingKey, value);
}

/// In-memory implementation for tests.
class InMemoryPreferencesStore implements PreferencesStore {
  InMemoryPreferencesStore([this._onboardingAccepted = false]);

  bool _onboardingAccepted;

  @override
  bool get onboardingAccepted => _onboardingAccepted;

  @override
  Future<void> setOnboardingAccepted(bool value) async {
    _onboardingAccepted = value;
  }
}
