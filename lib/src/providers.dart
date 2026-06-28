import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

import 'data/activity_repository.dart';
import 'data/persistent_repository.dart';

/// Ticks once per second so the UI re-evaluates the (pure) engine. The engine
/// itself holds no timer.
final nowProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now().toUtc();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now().toUtc(),
  );
});

final rulesProvider = Provider<RulesPack>((ref) => RulesPack.defaultEuPl);

final safetyBufferProvider =
    Provider<Duration>((ref) => const Duration(minutes: 30));

/// Base time zone for week/duty boundaries. Driver-configurable later.
final baseLocationProvider =
    Provider<tz.Location>((ref) => tz.getLocation('Europe/Warsaw'));

final engineProvider = Provider<ComplianceEngine>((ref) => ComplianceEngine());

/// Activity storage — Drift (SQLite) on device, in-memory on web / in tests.
final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  final repository = createPersistentRepository();
  ref.onDispose(repository.dispose);
  return repository;
});

/// Live activity log, oldest first.
final activityEventsProvider = StreamProvider<List<ActivityEvent>>((ref) {
  return ref.watch(activityRepositoryProvider).watch();
});

/// Full compliance snapshot, recomputed on each clock tick or log change.
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
      );
});
