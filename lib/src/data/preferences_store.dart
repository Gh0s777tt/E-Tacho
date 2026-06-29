import 'package:shared_preferences/shared_preferences.dart';

/// Small key-value settings: consent flag, warning buffer, base time zone,
/// locale override and crew (multi-manning) mode.
abstract class PreferencesStore {
  bool get onboardingAccepted;
  Future<void> setOnboardingAccepted(bool value);

  int get bufferMinutes;
  Future<void> setBufferMinutes(int value);

  String get timeZoneId;
  Future<void> setTimeZoneId(String value);

  /// Null means "follow the system language".
  String? get localeCode;
  Future<void> setLocaleCode(String? value);

  bool get crewMode;
  Future<void> setCrewMode(bool value);
}

class SharedPreferencesStore implements PreferencesStore {
  SharedPreferencesStore(this._prefs);

  final SharedPreferences _prefs;
  static const String _onboardingKey = 'onboarding_accepted';
  static const String _bufferKey = 'buffer_minutes';
  static const String _timeZoneKey = 'time_zone_id';
  static const String _localeKey = 'locale_code';
  static const String _crewKey = 'crew_mode';

  @override
  bool get onboardingAccepted => _prefs.getBool(_onboardingKey) ?? false;
  @override
  Future<void> setOnboardingAccepted(bool value) =>
      _prefs.setBool(_onboardingKey, value);

  @override
  int get bufferMinutes => _prefs.getInt(_bufferKey) ?? 30;
  @override
  Future<void> setBufferMinutes(int value) => _prefs.setInt(_bufferKey, value);

  @override
  String get timeZoneId => _prefs.getString(_timeZoneKey) ?? 'Europe/Warsaw';
  @override
  Future<void> setTimeZoneId(String value) =>
      _prefs.setString(_timeZoneKey, value);

  @override
  String? get localeCode => _prefs.getString(_localeKey);
  @override
  Future<void> setLocaleCode(String? value) async {
    if (value == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, value);
    }
  }

  @override
  bool get crewMode => _prefs.getBool(_crewKey) ?? false;
  @override
  Future<void> setCrewMode(bool value) => _prefs.setBool(_crewKey, value);
}

/// In-memory implementation for tests.
class InMemoryPreferencesStore implements PreferencesStore {
  InMemoryPreferencesStore([this._onboardingAccepted = false]);

  bool _onboardingAccepted;
  int _bufferMinutes = 30;
  String _timeZoneId = 'Europe/Warsaw';
  String? _localeCode;
  bool _crewMode = false;

  @override
  bool get onboardingAccepted => _onboardingAccepted;
  @override
  Future<void> setOnboardingAccepted(bool value) async {
    _onboardingAccepted = value;
  }

  @override
  int get bufferMinutes => _bufferMinutes;
  @override
  Future<void> setBufferMinutes(int value) async {
    _bufferMinutes = value;
  }

  @override
  String get timeZoneId => _timeZoneId;
  @override
  Future<void> setTimeZoneId(String value) async {
    _timeZoneId = value;
  }

  @override
  String? get localeCode => _localeCode;
  @override
  Future<void> setLocaleCode(String? value) async {
    _localeCode = value;
  }

  @override
  bool get crewMode => _crewMode;
  @override
  Future<void> setCrewMode(bool value) async {
    _crewMode = value;
  }
}
