import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'auth/auth_service.dart';
import 'data/activity_repository.dart';
import 'data/persistent_repository.dart';
import 'data/preferences_store.dart';
import 'detection/driving_detector.dart';
import 'notifications/notification_service.dart';
import 'widget/home_widget_service.dart';

/// Ticks once per second so the UI re-evaluates the (pure) engine.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now().toUtc();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().toUtc(),
  );
});

final rulesProvider = Provider<RulesPack>((ref) => RulesPack.defaultEuPl);

final engineProvider = Provider<ComplianceEngine>((ref) => ComplianceEngine());

// ── Settings ────────────────────────────────────────────────────────────────

class SettingsState {
  const SettingsState({
    required this.bufferMinutes,
    required this.timeZoneId,
    required this.localeCode,
    required this.crewMode,
  });

  final int bufferMinutes;
  final String timeZoneId;
  final String? localeCode;
  final bool crewMode;
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._store)
      : super(SettingsState(
          bufferMinutes: _store.bufferMinutes,
          timeZoneId: _store.timeZoneId,
          localeCode: _store.localeCode,
          crewMode: _store.crewMode,
        ));

  final PreferencesStore _store;

  Future<void> setBufferMinutes(int value) async {
    await _store.setBufferMinutes(value);
    state = SettingsState(
      bufferMinutes: value,
      timeZoneId: state.timeZoneId,
      localeCode: state.localeCode,
      crewMode: state.crewMode,
    );
  }

  Future<void> setTimeZoneId(String value) async {
    await _store.setTimeZoneId(value);
    state = SettingsState(
      bufferMinutes: state.bufferMinutes,
      timeZoneId: value,
      localeCode: state.localeCode,
      crewMode: state.crewMode,
    );
  }

  Future<void> setLocaleCode(String? value) async {
    await _store.setLocaleCode(value);
    state = SettingsState(
      bufferMinutes: state.bufferMinutes,
      timeZoneId: state.timeZoneId,
      localeCode: value,
      crewMode: state.crewMode,
    );
  }

  Future<void> setCrewMode(bool value) async {
    await _store.setCrewMode(value);
    state = SettingsState(
      bufferMinutes: state.bufferMinutes,
      timeZoneId: state.timeZoneId,
      localeCode: state.localeCode,
      crewMode: value,
    );
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
  (ref) => SettingsController(ref.watch(preferencesStoreProvider)),
);

final safetyBufferProvider = Provider<Duration>(
  (ref) => Duration(minutes: ref.watch(settingsProvider).bufferMinutes),
);

/// Base time zone for week/duty boundaries (driver-set in settings).
final baseLocationProvider = Provider<tz.Location>(
  (ref) => tz.getLocation(ref.watch(settingsProvider).timeZoneId),
);

/// Locale override; null follows the system language.
final localeProvider = Provider<Locale?>((ref) {
  final code = ref.watch(settingsProvider).localeCode;
  return code == null ? null : Locale(code);
});

final dutyModeProvider = Provider<DutyMode>(
  (ref) => ref.watch(settingsProvider).crewMode ? DutyMode.crew : DutyMode.solo,
);

// ── Activity storage ──────────────────────────────────────────────────────

/// Drift (SQLite) on device, in-memory on web / in tests.
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final repository = createPersistentRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

final activityEventsProvider = StreamProvider<List<ActivityEvent>>((ref) {
  return ref.watch(activityRepositoryProvider).watch();
});

final complianceProvider = Provider<ComplianceState>((ref) {
  final now = ref.watch(nowProvider).valueOrNull ?? DateTime.now().toUtc();
  final events =
      ref.watch(activityEventsProvider).valueOrNull ?? const <ActivityEvent>[];
  return ref.watch(engineProvider).evaluate(
        events: events,
        rules: ref.watch(rulesProvider),
        now: now,
        timeZone: ref.watch(baseLocationProvider),
        safetyBuffer: ref.watch(safetyBufferProvider),
        dutyMode: ref.watch(dutyModeProvider),
      );
});

// ── Preferences / onboarding ────────────────────────────────────────────────

/// Overridden in main with a SharedPreferences-backed store.
final preferencesStoreProvider = Provider<PreferencesStore>((ref) {
  throw UnimplementedError('preferencesStoreProvider must be overridden');
});

class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._store) : super(_store.onboardingAccepted);

  final PreferencesStore _store;

  Future<void> accept() async {
    await _store.setOnboardingAccepted(true);
    state = true;
  }
}

final onboardingAcceptedProvider =
    StateNotifierProvider<OnboardingController, bool>(
  (ref) => OnboardingController(ref.watch(preferencesStoreProvider)),
);

// ── Notifications ───────────────────────────────────────────────────────────

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

/// Planned notifications, recomputed when the activity log or settings change
/// (not on every clock tick — the fire times are absolute).
final plannedNotificationsProvider = Provider<List<PlannedNotification>>((ref) {
  final events =
      ref.watch(activityEventsProvider).valueOrNull ?? const <ActivityEvent>[];
  final buffer = ref.watch(safetyBufferProvider);
  final now = DateTime.now().toUtc();
  final state = ref.watch(engineProvider).evaluate(
        events: events,
        rules: ref.watch(rulesProvider),
        now: now,
        timeZone: ref.watch(baseLocationProvider),
        safetyBuffer: buffer,
        dutyMode: ref.watch(dutyModeProvider),
      );
  final leads = <Duration>{buffer, const Duration(minutes: 15), Duration.zero}
      .toList()
    ..sort((a, b) => b.compareTo(a));
  return const NotificationPlanner().plan(
    state: state,
    now: now,
    prefs: NotificationPreferences(leadTimes: leads),
  );
});

// ── Driving detection (skeleton) ────────────────────────────────────────────

final drivingDetectorProvider = Provider<DrivingDetector>((ref) {
  final detector = StubDrivingDetector();
  ref.onDispose(detector.dispose);
  return detector;
});

// ── Home-screen widget ──────────────────────────────────────────────────────

final homeWidgetServiceProvider =
    Provider<HomeWidgetService>((ref) => HomeWidgetService());

// ── Auth ────────────────────────────────────────────────────────────────────

/// Stub now; swap for a Supabase-backed implementation behind this provider.
final authServiceProvider = Provider<AuthService>((ref) {
  final service = StubAuthService();
  ref.onDispose(service.dispose);
  return service;
});

final authStateProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authServiceProvider).authState(),
);
