import 'package:compliance_engine/compliance_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

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

/// Base time zone for week/duty boundaries. Driver-configurable in a later
/// settings screen; defaults to the home zone.
final baseLocationProvider =
    Provider<tz.Location>((ref) => tz.getLocation('Europe/Warsaw'));

final engineProvider = Provider<ComplianceEngine>((ref) => ComplianceEngine());

/// In-memory activity log for the MVP shell (Drift persistence comes later).
class ActivityStore extends StateNotifier<List<ActivityEvent>> {
  ActivityStore() : super(const []);

  int _seq = 0;

  void setActivity(ActivityType type) {
    state = [
      ...state,
      ActivityEvent(
        id: 'e${_seq++}',
        type: type,
        startTime: DateTime.now().toUtc(),
      ),
    ];
  }

  void reset() {
    _seq = 0;
    state = const [];
  }
}

final activityStoreProvider =
    StateNotifierProvider<ActivityStore, List<ActivityEvent>>(
  (ref) => ActivityStore(),
);

/// The full compliance snapshot, recomputed whenever the clock ticks or the
/// activity log changes.
final complianceProvider = Provider<ComplianceState>((ref) {
  final now = ref.watch(nowProvider).valueOrNull ?? DateTime.now().toUtc();
  return ref.watch(engineProvider).evaluate(
        events: ref.watch(activityStoreProvider),
        rules: ref.watch(rulesProvider),
        now: now,
        timeZone: ref.watch(baseLocationProvider),
        safetyBuffer: ref.watch(safetyBufferProvider),
      );
});
