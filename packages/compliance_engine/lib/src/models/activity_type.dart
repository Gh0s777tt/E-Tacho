/// Tachograph-aligned driver activity states.
///
/// A single [rest] state covers both *breaks* and *rest periods*: in
/// tachograph terms the card is simply in "rest" mode. The engine classifies a
/// `rest` interval as a break, a daily rest or a weekly rest based on its
/// duration and context, not on a separate event type.
enum ActivityType {
  /// Driving (jazda).
  driving,

  /// Other work, e.g. loading/unloading (inna praca).
  otherWork,

  /// Availability / waiting time (dyspozycyjność) — used mainly in crew mode.
  availability,

  /// Break or rest (przerwa / odpoczynek).
  rest,
}

/// Where an [ActivityEvent] came from.
enum ActivitySource {
  /// Entered by the driver (including onboarding backfill).
  manual,

  /// Detected automatically (activity recognition / motion sensors).
  auto,
}

/// Convenience predicates used by the counters.
extension ActivityTypeX on ActivityType {
  bool get isDriving => this == ActivityType.driving;

  bool get isRest => this == ActivityType.rest;

  /// Working time = driving + other work (EU/PL working-time definition).
  /// Availability and rest are excluded.
  bool get isWorkingTime =>
      this == ActivityType.driving || this == ActivityType.otherWork;
}
