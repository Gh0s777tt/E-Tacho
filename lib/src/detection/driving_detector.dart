import 'dart:async';

/// Emits a candidate driving-start instant (UTC), surfaced for confirmation
/// after the vehicle stops ("start driving from 8:14?"). This is the skeleton
/// from §4.3; real activity recognition is wired later.
abstract class DrivingDetector {
  Stream<DateTime> get detections;
  Future<void> dispose();
}

/// Default placeholder — no automatic detection yet.
// TODO: integrate activity recognition / motion sensors (needs platform perms).
class StubDrivingDetector implements DrivingDetector {
  @override
  Stream<DateTime> get detections => const Stream<DateTime>.empty();

  @override
  Future<void> dispose() async {}
}

/// Detector driven manually — for tests and demos.
class SimulatedDrivingDetector implements DrivingDetector {
  final StreamController<DateTime> _controller =
      StreamController<DateTime>.broadcast();

  @override
  Stream<DateTime> get detections => _controller.stream;

  /// Simulates detecting that driving began at [startedAtUtc].
  void simulate(DateTime startedAtUtc) => _controller.add(startedAtUtc);

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}
