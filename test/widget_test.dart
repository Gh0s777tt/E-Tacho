import 'package:e_tacho/src/app.dart';
import 'package:e_tacho/src/data/activity_repository.dart';
import 'package:e_tacho/src/providers.dart';
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
}
