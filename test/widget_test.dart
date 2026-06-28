import 'package:e_tacho/src/app.dart';
import 'package:e_tacho/src/data/activity_repository.dart';
import 'package:e_tacho/src/data/preferences_store.dart';
import 'package:e_tacho/src/providers.dart';
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
}
