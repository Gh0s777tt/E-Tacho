import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Thrown when a [RulesPack] JSON document is missing fields or has invalid
/// values.
class RulesPackFormatException implements Exception {
  const RulesPackFormatException(this.message);

  final String message;

  @override
  String toString() => 'RulesPackFormatException: $message';
}

/// Versioned, server-fetched set of regulatory limits.
///
/// The engine reads every limit from this object — no numeric limit is ever
/// hardcoded in the counting logic. This lets limits change (a new rules pack
/// fetched from the server and cached locally) without shipping a new build.
///
/// All values marked `// TODO: zweryfikować z przepisami` are treated as
/// defaults pending legal review.
@immutable
class RulesPack extends Equatable {
  const RulesPack({
    required this.version,
    required this.continuousDrivingMax,
    required this.breakRequired,
    required this.breakSplit,
    required this.dailyDrivingMax,
    required this.dailyDrivingExtended,
    required this.extendedDrivingDaysPerWeekMax,
    required this.dailyRestRegular,
    required this.dailyRestReduced,
    required this.reducedDailyRestsBetweenWeeklyMax,
    required this.dailyRestSplitFirst,
    required this.weeklyDrivingMax,
    required this.twoWeeklyDrivingMax,
    required this.dutyWindowSolo,
    required this.dutyWindowCrew,
    required this.weeklyRestRegular,
    required this.weeklyRestReduced,
    required this.weeklyRestWindow,
    required this.reducedWeeklyRestsPerFortnightMax,
    required this.weeklyWorkingTimeMax,
    required this.weeklyWorkingTimeAverage,
    required this.nightWorkMaxPerDuty,
    required this.nightWindowStart,
    required this.nightWindowEnd,
    required this.workBreakAfterWork,
    required this.workBreakShort,
    required this.workBreakLong,
    required this.workBreakLongThresholdWork,
    required this.workBreakMinPart,
  });

  final String version;

  // ── EU Regulation (EC) 561/2006 ──────────────────────────────────────────
  /// Max continuous driving before a break is required (4h30).
  final Duration continuousDrivingMax;

  /// Required break after continuous driving (45m).
  final Duration breakRequired;

  /// Allowed split of the required break, ORDER SIGNIFICANT: a first part of at
  /// least `breakSplit[0]` (15m) followed by a second part of at least
  /// `breakSplit[1]` (30m).
  final List<Duration> breakSplit;

  /// Max daily driving (9h).
  final Duration dailyDrivingMax;

  /// Extended daily driving ceiling (10h), allowed up to
  /// [extendedDrivingDaysPerWeekMax] times per week.
  final Duration dailyDrivingExtended;
  final int extendedDrivingDaysPerWeekMax;

  /// Regular daily rest (11h).
  final Duration dailyRestRegular;

  /// Reduced daily rest (9h), allowed up to
  /// [reducedDailyRestsBetweenWeeklyMax] times between two weekly rests.
  final Duration dailyRestReduced;
  final int reducedDailyRestsBetweenWeeklyMax;

  /// First part of a split daily rest (EU 561 art. 8(2): >= 3h, then >= 9h).
  /// A valid 3h+9h split is a *regular* rest, so it does not consume a reduced
  /// daily-rest allowance.
  final Duration dailyRestSplitFirst;

  /// Max weekly driving (56h).
  final Duration weeklyDrivingMax;

  /// Max driving across two consecutive weeks (90h).
  final Duration twoWeeklyDrivingMax;

  /// Window from the end of the previous daily/weekly rest within which a new
  /// daily rest must be taken — solo (24h) and crew (30h).
  final Duration dutyWindowSolo;
  final Duration dutyWindowCrew;

  /// Weekly rest thresholds. Full weekly-rest tracking + compensation is a
  /// stage-2 feature; here they are used only to detect the boundary between
  /// "weekly rest" groups for the reduced-daily-rest counter.
  // TODO: zweryfikować z przepisami — pełne śledzenie odpoczynku tygodniowego (etap 2).
  final Duration weeklyRestRegular;
  final Duration weeklyRestReduced;

  /// A weekly rest must START within this window from the end of the previous
  /// weekly rest (EU 561 art. 8(6): six 24h periods = 144h).
  final Duration weeklyRestWindow;

  /// Max reduced weekly rests in any two consecutive weeks (EU 561 art. 8(6)).
  final int reducedWeeklyRestsPerFortnightMax;

  // ── Polish Drivers' Working Time Act ─────────────────────────────────────
  /// Single-week working-time ceiling (60h).
  final Duration weeklyWorkingTimeMax;

  /// Average weekly working time over the reference period (48h). Averaging
  /// over the multi-month reference period is a stage-2 feature.
  // TODO: zweryfikować z przepisami — uśrednianie w okresie rozliczeniowym (etap 2).
  final Duration weeklyWorkingTimeAverage;

  /// Max working time within a duty period when any night work is performed
  /// (10h).
  final Duration nightWorkMaxPerDuty;

  /// Night window, expressed as a duration from local midnight. Polish law
  /// defines "pora nocna" as a 4-hour span set within 00:00–07:00.
  // TODO: zweryfikować z przepisami — dokładne okno pory nocnej (pracodawca ustala 4h w 00:00-07:00).
  final Duration nightWindowStart;
  final Duration nightWindowEnd;

  /// PL art. 13: a break is due after this much consecutive work.
  final Duration workBreakAfterWork;

  /// Required break length: [workBreakShort] when daily work is at or below
  /// [workBreakLongThresholdWork], otherwise [workBreakLong]. The break may be
  /// split into parts of at least [workBreakMinPart].
  final Duration workBreakShort;
  final Duration workBreakLong;
  final Duration workBreakLongThresholdWork;
  final Duration workBreakMinPart;

  /// Default EU 561/2006 + Polish working-time pack. Values are defaults
  /// pending legal verification.
  static const RulesPack defaultEuPl = RulesPack(
    version: '2026.07-EU-561-PL',
    continuousDrivingMax: Duration(minutes: 270),
    breakRequired: Duration(minutes: 45),
    breakSplit: [Duration(minutes: 15), Duration(minutes: 30)],
    dailyDrivingMax: Duration(minutes: 540),
    dailyDrivingExtended: Duration(minutes: 600),
    extendedDrivingDaysPerWeekMax: 2,
    dailyRestRegular: Duration(minutes: 660),
    dailyRestReduced: Duration(minutes: 540),
    reducedDailyRestsBetweenWeeklyMax: 3,
    dailyRestSplitFirst: Duration(minutes: 180),
    weeklyDrivingMax: Duration(minutes: 3360),
    twoWeeklyDrivingMax: Duration(minutes: 5400),
    dutyWindowSolo: Duration(minutes: 1440),
    dutyWindowCrew: Duration(minutes: 1800),
    weeklyRestRegular: Duration(minutes: 2700),
    weeklyRestReduced: Duration(minutes: 1440),
    weeklyRestWindow: Duration(minutes: 8640),
    reducedWeeklyRestsPerFortnightMax: 1,
    weeklyWorkingTimeMax: Duration(minutes: 3600),
    weeklyWorkingTimeAverage: Duration(minutes: 2880),
    nightWorkMaxPerDuty: Duration(minutes: 600),
    nightWindowStart: Duration.zero,
    nightWindowEnd: Duration(minutes: 240),
    workBreakAfterWork: Duration(minutes: 360),
    workBreakShort: Duration(minutes: 30),
    workBreakLong: Duration(minutes: 45),
    workBreakLongThresholdWork: Duration(minutes: 540),
    workBreakMinPart: Duration(minutes: 15),
  );

  factory RulesPack.fromJson(Map<String, dynamic> json) {
    final version = json['version'];
    if (version is! String) {
      throw const RulesPackFormatException('missing or non-string "version"');
    }
    final split = json['break_split'];
    if (split is! List || split.isEmpty) {
      throw const RulesPackFormatException('missing or empty "break_split"');
    }
    final pack = RulesPack(
      version: version,
      continuousDrivingMax: _min(json, 'continuous_driving_max_min'),
      breakRequired: _min(json, 'break_required_min'),
      breakSplit: split
          .map((m) => Duration(minutes: (m as num).round()))
          .toList(growable: false),
      dailyDrivingMax: _min(json, 'daily_driving_max_min'),
      dailyDrivingExtended: _min(json, 'daily_driving_extended_min'),
      extendedDrivingDaysPerWeekMax:
          _int(json, 'extended_driving_days_per_week_max'),
      dailyRestRegular: _min(json, 'daily_rest_regular_min'),
      dailyRestReduced: _min(json, 'daily_rest_reduced_min'),
      reducedDailyRestsBetweenWeeklyMax:
          _int(json, 'reduced_daily_rests_between_weekly_max'),
      dailyRestSplitFirst: _minOr(
          json, 'daily_rest_split_first_min', defaultEuPl.dailyRestSplitFirst),
      weeklyDrivingMax: _min(json, 'weekly_driving_max_min'),
      twoWeeklyDrivingMax: _min(json, 'two_weekly_driving_max_min'),
      dutyWindowSolo: _min(json, 'duty_window_solo_min'),
      dutyWindowCrew: _min(json, 'duty_window_crew_min'),
      nightWorkMaxPerDuty: _min(json, 'night_work_max_between_rests_min'),
      // Additive (PL / stage-2) keys: fall back to defaults when absent so an
      // older cached pack still loads.
      weeklyRestRegular:
          _minOr(json, 'weekly_rest_regular_min', defaultEuPl.weeklyRestRegular),
      weeklyRestReduced:
          _minOr(json, 'weekly_rest_reduced_min', defaultEuPl.weeklyRestReduced),
      weeklyRestWindow: _minOr(
          json, 'weekly_rest_window_min', defaultEuPl.weeklyRestWindow),
      reducedWeeklyRestsPerFortnightMax: _intOr(
          json,
          'reduced_weekly_rests_per_fortnight_max',
          defaultEuPl.reducedWeeklyRestsPerFortnightMax),
      weeklyWorkingTimeMax: _minOr(
          json, 'weekly_working_time_max_min', defaultEuPl.weeklyWorkingTimeMax),
      weeklyWorkingTimeAverage: _minOr(json, 'weekly_working_time_average_min',
          defaultEuPl.weeklyWorkingTimeAverage),
      nightWindowStart:
          _minOr(json, 'night_window_start_min', defaultEuPl.nightWindowStart),
      nightWindowEnd:
          _minOr(json, 'night_window_end_min', defaultEuPl.nightWindowEnd),
      workBreakAfterWork: _minOr(
          json, 'work_break_after_work_min', defaultEuPl.workBreakAfterWork),
      workBreakShort:
          _minOr(json, 'work_break_short_min', defaultEuPl.workBreakShort),
      workBreakLong:
          _minOr(json, 'work_break_long_min', defaultEuPl.workBreakLong),
      workBreakLongThresholdWork: _minOr(
          json,
          'work_break_long_threshold_work_min',
          defaultEuPl.workBreakLongThresholdWork),
      workBreakMinPart: _minOr(
          json, 'work_break_min_part_min', defaultEuPl.workBreakMinPart),
    )..validate();
    return pack;
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'continuous_driving_max_min': continuousDrivingMax.inMinutes,
        'break_required_min': breakRequired.inMinutes,
        'break_split': breakSplit.map((d) => d.inMinutes).toList(),
        'daily_driving_max_min': dailyDrivingMax.inMinutes,
        'daily_driving_extended_min': dailyDrivingExtended.inMinutes,
        'extended_driving_days_per_week_max': extendedDrivingDaysPerWeekMax,
        'daily_rest_regular_min': dailyRestRegular.inMinutes,
        'daily_rest_reduced_min': dailyRestReduced.inMinutes,
        'reduced_daily_rests_between_weekly_max':
            reducedDailyRestsBetweenWeeklyMax,
        'daily_rest_split_first_min': dailyRestSplitFirst.inMinutes,
        'weekly_driving_max_min': weeklyDrivingMax.inMinutes,
        'two_weekly_driving_max_min': twoWeeklyDrivingMax.inMinutes,
        'duty_window_solo_min': dutyWindowSolo.inMinutes,
        'duty_window_crew_min': dutyWindowCrew.inMinutes,
        'weekly_rest_regular_min': weeklyRestRegular.inMinutes,
        'weekly_rest_reduced_min': weeklyRestReduced.inMinutes,
        'weekly_rest_window_min': weeklyRestWindow.inMinutes,
        'reduced_weekly_rests_per_fortnight_max':
            reducedWeeklyRestsPerFortnightMax,
        'weekly_working_time_max_min': weeklyWorkingTimeMax.inMinutes,
        'weekly_working_time_average_min': weeklyWorkingTimeAverage.inMinutes,
        'night_work_max_between_rests_min': nightWorkMaxPerDuty.inMinutes,
        'night_window_start_min': nightWindowStart.inMinutes,
        'night_window_end_min': nightWindowEnd.inMinutes,
        'work_break_after_work_min': workBreakAfterWork.inMinutes,
        'work_break_short_min': workBreakShort.inMinutes,
        'work_break_long_min': workBreakLong.inMinutes,
        'work_break_long_threshold_work_min':
            workBreakLongThresholdWork.inMinutes,
        'work_break_min_part_min': workBreakMinPart.inMinutes,
      };

  /// Validates internal consistency. Throws [RulesPackFormatException].
  void validate() {
    void positive(Duration d, String name) {
      if (d <= Duration.zero) {
        throw RulesPackFormatException('"$name" must be positive');
      }
    }

    positive(continuousDrivingMax, 'continuous_driving_max_min');
    positive(breakRequired, 'break_required_min');
    positive(dailyDrivingMax, 'daily_driving_max_min');
    positive(weeklyDrivingMax, 'weekly_driving_max_min');
    positive(dailyRestReduced, 'daily_rest_reduced_min');

    if (breakSplit.length != 2) {
      throw const RulesPackFormatException(
          '"break_split" must have exactly 2 parts [first, second]');
    }
    if (breakSplit.any((d) => d <= Duration.zero)) {
      throw const RulesPackFormatException('"break_split" parts must be positive');
    }
    if (dailyDrivingExtended < dailyDrivingMax) {
      throw const RulesPackFormatException(
          'daily_driving_extended_min must be >= daily_driving_max_min');
    }
    if (dailyRestReduced > dailyRestRegular) {
      throw const RulesPackFormatException(
          'daily_rest_reduced_min must be <= daily_rest_regular_min');
    }
    if (dailyRestSplitFirst <= Duration.zero ||
        dailyRestSplitFirst >= dailyRestReduced) {
      throw const RulesPackFormatException(
          'daily_rest_split_first_min must be > 0 and < daily_rest_reduced_min');
    }
    if (twoWeeklyDrivingMax < weeklyDrivingMax) {
      throw const RulesPackFormatException(
          'two_weekly_driving_max_min must be >= weekly_driving_max_min');
    }
    if (extendedDrivingDaysPerWeekMax < 0 ||
        reducedDailyRestsBetweenWeeklyMax < 0 ||
        reducedWeeklyRestsPerFortnightMax < 0) {
      throw const RulesPackFormatException('count limits must be >= 0');
    }
    if (weeklyRestWindow <= Duration.zero) {
      throw const RulesPackFormatException(
          'weekly_rest_window_min must be positive');
    }
    if (nightWindowEnd <= nightWindowStart) {
      // TODO: support a night window that wraps past midnight.
      throw const RulesPackFormatException(
          'night_window_end_min must be > night_window_start_min');
    }
    positive(workBreakAfterWork, 'work_break_after_work_min');
    positive(workBreakMinPart, 'work_break_min_part_min');
    if (workBreakShort > workBreakLong) {
      throw const RulesPackFormatException(
          'work_break_short_min must be <= work_break_long_min');
    }
    if (workBreakMinPart > workBreakShort) {
      throw const RulesPackFormatException(
          'work_break_min_part_min must be <= work_break_short_min');
    }
  }

  static Duration _min(Map<String, dynamic> j, String key) {
    final v = j[key];
    if (v is! num) {
      throw RulesPackFormatException('missing or non-numeric "$key"');
    }
    return Duration(minutes: v.round());
  }

  static Duration _minOr(Map<String, dynamic> j, String key, Duration fallback) {
    final v = j[key];
    return v is num ? Duration(minutes: v.round()) : fallback;
  }

  static int _int(Map<String, dynamic> j, String key) {
    final v = j[key];
    if (v is! num) {
      throw RulesPackFormatException('missing or non-numeric "$key"');
    }
    return v.toInt();
  }

  static int _intOr(Map<String, dynamic> j, String key, int fallback) {
    final v = j[key];
    return v is num ? v.toInt() : fallback;
  }

  @override
  List<Object?> get props => [
        version,
        continuousDrivingMax,
        breakRequired,
        breakSplit,
        dailyDrivingMax,
        dailyDrivingExtended,
        extendedDrivingDaysPerWeekMax,
        dailyRestRegular,
        dailyRestReduced,
        reducedDailyRestsBetweenWeeklyMax,
        dailyRestSplitFirst,
        weeklyDrivingMax,
        twoWeeklyDrivingMax,
        dutyWindowSolo,
        dutyWindowCrew,
        weeklyRestRegular,
        weeklyRestReduced,
        weeklyRestWindow,
        reducedWeeklyRestsPerFortnightMax,
        weeklyWorkingTimeMax,
        weeklyWorkingTimeAverage,
        nightWorkMaxPerDuty,
        nightWindowStart,
        nightWindowEnd,
        workBreakAfterWork,
        workBreakShort,
        workBreakLong,
        workBreakLongThresholdWork,
        workBreakMinPart,
      ];
}
