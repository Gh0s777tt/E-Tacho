import 'package:compliance_engine/compliance_engine.dart';
import 'package:test/test.dart';

void main() {
  group('RulesPack', () {
    Map<String, dynamic> exampleJson() => <String, dynamic>{
          'version': '2026.07-EU-561',
          'continuous_driving_max_min': 270,
          'break_required_min': 45,
          'break_split': [15, 30],
          'daily_driving_max_min': 540,
          'daily_driving_extended_min': 600,
          'extended_driving_days_per_week_max': 2,
          'daily_rest_regular_min': 660,
          'daily_rest_reduced_min': 540,
          'reduced_daily_rests_between_weekly_max': 3,
          'weekly_driving_max_min': 3360,
          'two_weekly_driving_max_min': 5400,
          'duty_window_solo_min': 1440,
          'duty_window_crew_min': 1800,
          'night_work_max_between_rests_min': 600,
        };

    test('parses the example pack and falls back to defaults for PL keys', () {
      final pack = RulesPack.fromJson(exampleJson());
      expect(pack.version, '2026.07-EU-561');
      expect(pack.continuousDrivingMax, const Duration(minutes: 270));
      expect(pack.breakSplit,
          const [Duration(minutes: 15), Duration(minutes: 30)]);
      expect(pack.dutyWindowSolo, const Duration(hours: 24));
      expect(pack.nightWorkMaxPerDuty, const Duration(minutes: 600));
      // PL-only key absent from the example -> default fallback, not a crash.
      expect(pack.weeklyWorkingTimeMax,
          RulesPack.defaultEuPl.weeklyWorkingTimeMax);
    });

    test('toJson / fromJson round-trips the default pack', () {
      final pack = RulesPack.fromJson(RulesPack.defaultEuPl.toJson());
      expect(pack, RulesPack.defaultEuPl);
    });

    test('throws on a missing required key', () {
      final bad = exampleJson()..remove('break_required_min');
      expect(() => RulesPack.fromJson(bad),
          throwsA(isA<RulesPackFormatException>()));
    });

    test('validate rejects extended < regular daily driving', () {
      final bad = exampleJson()..['daily_driving_extended_min'] = 500;
      expect(() => RulesPack.fromJson(bad),
          throwsA(isA<RulesPackFormatException>()));
    });

    test('validate rejects a malformed break split', () {
      final bad = exampleJson()..['break_split'] = [15, 30, 10];
      expect(() => RulesPack.fromJson(bad),
          throwsA(isA<RulesPackFormatException>()));
    });
  });
}
