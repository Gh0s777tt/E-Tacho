import 'package:e_tacho/src/app.dart';
import 'package:e_tacho/src/auth/auth_service.dart';
import 'package:e_tacho/src/data/activity_repository.dart';
import 'package:e_tacho/src/data/preferences_store.dart';
import 'package:e_tacho/src/detection/driving_detector.dart';
import 'package:e_tacho/src/notifications/notification_service.dart';
import 'package:e_tacho/src/providers.dart';
import 'package:e_tacho/src/widget/home_widget_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  testWidgets('home renders; tapping Drive updates the current state',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Fixed clock so the test does not depend on the 1s ticker.
          nowProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime.utc(2035, 1, 1)),
          ),
          // In-memory storage so the test needs no native SQLite / file system.
          activityRepositoryProvider
              .overrideWithValue(InMemoryActivityRepository()),
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(true),
          ),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
          homeWidgetServiceProvider
              .overrideWithValue(_NoopHomeWidgetService()),
          authServiceProvider.overrideWithValue(
            StubAuthService(initialUser: const AuthUser(id: 'test')),
          ),
        ],
        child: const ETachoApp(),
      ),
    );
    await tester.pump();

    expect(find.text('E-Tacho'), findsOneWidget);
    expect(find.text('Drive'), findsOneWidget);

    await tester.tap(find.text('Drive'));
    await tester.pump();
    await tester.pump();

    // The current-state bar now reflects driving.
    expect(find.text('Driving'), findsWidgets);
  });

  testWidgets('opens the history screen from the app bar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime.utc(2035, 1, 1)),
          ),
          activityRepositoryProvider
              .overrideWithValue(InMemoryActivityRepository()),
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(true),
          ),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
          homeWidgetServiceProvider
              .overrideWithValue(_NoopHomeWidgetService()),
          authServiceProvider.overrideWithValue(
            StubAuthService(initialUser: const AuthUser(id: 'test')),
          ),
        ],
        child: const ETachoApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.history));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('No activity recorded yet.'), findsOneWidget);
  });

  testWidgets('onboarding gate: consent, then enter the app', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime.utc(2035, 1, 1)),
          ),
          activityRepositoryProvider
              .overrideWithValue(InMemoryActivityRepository()),
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(false),
          ),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
          homeWidgetServiceProvider
              .overrideWithValue(_NoopHomeWidgetService()),
          authServiceProvider.overrideWithValue(
            StubAuthService(initialUser: const AuthUser(id: 'test')),
          ),
        ],
        child: const ETachoApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // Consent accepted -> home screen is shown.
    expect(find.text('E-Tacho'), findsOneWidget);
  });

  testWidgets('opens the settings screen from the app bar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime.utc(2035, 1, 1)),
          ),
          activityRepositoryProvider
              .overrideWithValue(InMemoryActivityRepository()),
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(true),
          ),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
          homeWidgetServiceProvider
              .overrideWithValue(_NoopHomeWidgetService()),
          authServiceProvider.overrideWithValue(
            StubAuthService(initialUser: const AuthUser(id: 'test')),
          ),
        ],
        child: const ETachoApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Warning buffer'), findsOneWidget);
  });

  testWidgets('auto-detection prompt backfills a driving event on confirm',
      (tester) async {
    final detector = SimulatedDrivingDetector();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime.utc(2035, 1, 1)),
          ),
          activityRepositoryProvider
              .overrideWithValue(InMemoryActivityRepository()),
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(true),
          ),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
          homeWidgetServiceProvider
              .overrideWithValue(_NoopHomeWidgetService()),
          authServiceProvider.overrideWithValue(
            StubAuthService(initialUser: const AuthUser(id: 'test')),
          ),
          drivingDetectorProvider.overrideWithValue(detector),
        ],
        child: const ETachoApp(),
      ),
    );
    await tester.pumpAndSettle();

    detector.simulate(DateTime.utc(2034, 12, 31, 8, 14));
    await tester.pumpAndSettle();

    expect(find.text('Driving detected'), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.text('Driving'), findsWidgets);
  });

  testWidgets('auth gate: signing in reaches the home screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          nowProvider.overrideWith(
            (ref) => Stream<DateTime>.value(DateTime.utc(2035, 1, 1)),
          ),
          activityRepositoryProvider
              .overrideWithValue(InMemoryActivityRepository()),
          preferencesStoreProvider.overrideWithValue(
            InMemoryPreferencesStore(true),
          ),
          notificationServiceProvider
              .overrideWithValue(_NoopNotificationService()),
          homeWidgetServiceProvider
              .overrideWithValue(_NoopHomeWidgetService()),
          authServiceProvider.overrideWithValue(StubAuthService()),
        ],
        child: const ETachoApp(),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('submit')), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('email')), 'a@b.com');
    await tester.enterText(find.byKey(const ValueKey('password')), 'secret');
    await tester.tap(find.byKey(const ValueKey('submit')));
    await tester.pumpAndSettle();

    expect(find.text('E-Tacho'), findsOneWidget);
  });
}

class _NoopNotificationService extends NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<void> sync(List<ScheduledNotification> items) async {}
}

class _NoopHomeWidgetService extends HomeWidgetService {
  @override
  Future<void> update({
    required String breakLabel,
    required String breakValue,
    required String dutyLabel,
    required String dutyValue,
  }) async {}
}
