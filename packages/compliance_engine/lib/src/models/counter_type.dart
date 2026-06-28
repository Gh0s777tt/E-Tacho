/// The individual limits the engine tracks. One [CounterType] == one rule, each
/// implemented by an independently unit-tested counter.
enum CounterType {
  /// Continuous driving since the last qualifying break (EU: 4h30).
  continuousDriving,

  /// Daily driving since the last daily/weekly rest (EU: 9h / 10h).
  dailyDriving,

  /// Number of extended (10h) driving days used this week (EU: max 2).
  extendedDrivingDays,

  /// 24h window from the last rest within which a new daily rest must start.
  dutyWindow,

  /// Time available before the daily rest requirement (EU: 11h / 9h).
  dailyRest,

  /// Number of reduced (9h) daily rests used since the last weekly rest
  /// (EU: max 3).
  reducedDailyRests,

  /// Weekly driving (EU: 56h).
  weeklyDriving,

  /// Two-week (fortnightly) driving (EU: 90h).
  fortnightlyDriving,

  /// Weekly working time — driving + other work (PL: 60h single-week cap).
  weeklyWorkingTime,

  /// Working time within a duty period when night work is performed (PL: 10h).
  nightWork,

  /// Break required after consecutive working time (PL art. 13: 30/45 min).
  workingTimeBreak,
}

/// Severity of a counter relative to its limit and the driver's safety buffer.
/// Ordered from least to most severe (use [index] for comparison).
enum ComplianceLevel {
  /// Comfortably within limits.
  ok,

  /// Getting close — show an amber accent.
  approaching,

  /// Within the safety buffer of the limit — show a red accent.
  critical,

  /// Limit reached or exceeded.
  exceeded,
}

extension ComplianceLevelX on ComplianceLevel {
  bool isAtLeast(ComplianceLevel other) => index >= other.index;

  ComplianceLevel orHigher(ComplianceLevel other) =>
      index >= other.index ? this : other;
}
