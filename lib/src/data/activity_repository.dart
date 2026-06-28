import 'dart:async';

import 'package:compliance_engine/compliance_engine.dart';

/// Abstraction over activity-event storage. The app talks only to this; the
/// concrete store is Drift on device and in-memory on web / in tests.
abstract class ActivityRepository {
  /// Live stream of all events, oldest first.
  Stream<List<ActivityEvent>> watch();

  /// Appends an event of [type]. [at] enables onboarding backfill of an
  /// already-running activity; defaults to now.
  Future<void> add(ActivityType type, {DateTime? at});

  Future<void> clear();

  Future<void> dispose();
}

/// In-memory implementation (web fallback, tests, and onboarding previews).
class InMemoryActivityRepository implements ActivityRepository {
  final List<ActivityEvent> _events = [];
  final StreamController<List<ActivityEvent>> _controller =
      StreamController<List<ActivityEvent>>.broadcast();
  int _seq = 0;

  @override
  Stream<List<ActivityEvent>> watch() async* {
    yield List.unmodifiable(_events);
    yield* _controller.stream;
  }

  @override
  Future<void> add(ActivityType type, {DateTime? at}) async {
    _events
      ..add(ActivityEvent(
        id: 'mem-${_seq++}',
        type: type,
        startTime: (at ?? DateTime.now()).toUtc(),
      ))
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    _controller.add(List.unmodifiable(_events));
  }

  @override
  Future<void> clear() async {
    _events.clear();
    _controller.add(const []);
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
