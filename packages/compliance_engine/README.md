# compliance_engine

Pure-Dart rules engine for professional-driver working-time compliance under
**EU Regulation (EC) 561/2006** and the **Polish Drivers' Working Time Act**.

It has **no Flutter, UI or database dependencies** and is fully unit-testable
without an emulator. It is the safety-critical core of E-Tacho, deliberately kept
separate from the app so the counting logic can be reasoned about and tested in
isolation.

> ⚠️ A supporting tool only. The legal source of truth is the tachograph. This
> engine does not guarantee compliance.

## Design

- **State machine + counters.** `ActivityTimeline` turns a time-ordered stream of
  `ActivityEvent`s into closed intervals. Each rule is one `Counter`
  (independently unit-tested) producing a `CounterStatus` plus any
  `RequiredAction`s and `Violation`s.
- **Pure function.** `ComplianceEngine.evaluate(...)` is deterministic: no I/O,
  no timers, no globals. Recompute it on every UI tick — it is cheap.
- **Rules are data.** Every limit comes from a `RulesPack` (versioned, server-
  fetched, cached). No limit is hardcoded in the logic.
- **No baked-in strings.** Actions/violations carry i18n keys + args, never
  formatted text.
- **Fixed base time zone.** Week (Mon 00:00–Sun 24:00) and duty windows are
  computed in the driver's base time zone, DST-aware via `package:timezone`.

## Counters

| Counter | Rule | Default |
| --- | --- | --- |
| `continuousDriving` | break after continuous driving (45m, or 15+30 split) | 4h30 |
| `dailyDriving` | daily driving (9h, extendable to 10h) | 9h / 10h |
| `extendedDrivingDays` | extended (10h) days per week | max 2 |
| `dutyWindow` | window to start the next daily rest (solo) | 24h |
| `dailyRest` | daily rest (regular / reduced) | 11h / 9h |
| `reducedDailyRests` | reduced daily rests between weekly rests | max 3 |
| `weeklyDriving` | weekly driving | 56h |
| `fortnightlyDriving` | two-week driving | 90h |
| `weeklyWorkingTime` | PL: weekly working time (driving + other work) | 60h |
| `nightWork` | PL: working time per duty when night work is performed | 10h |
| `workingTimeBreak` | PL: break after consecutive work (art. 13) | 30/45 min after 6h |

See [`docs/LEGAL_VERIFICATION.md`](../../docs/LEGAL_VERIFICATION.md) for the
defaults pending legal review and the known gaps (split daily rest, weekly rest
+ compensation, crew mode).

## Usage

```dart
import 'package:compliance_engine/compliance_engine.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();
  final base = tz.getLocation('Europe/Warsaw');
  final engine = ComplianceEngine();

  final events = [
    ActivityEvent(
      id: '1',
      type: ActivityType.driving,
      startTime: DateTime.utc(2026, 6, 10, 6), // UTC
    ),
  ];

  final state = engine.evaluate(
    events: events,
    rules: RulesPack.defaultEuPl,
    now: DateTime.utc(2026, 6, 10, 10, 30),
    timeZone: base,
    safetyBuffer: const Duration(minutes: 30),
  );

  final driving = state.counter(CounterType.continuousDriving)!;
  print('Until break: ${driving.remaining}'); // 0:00:00 (4h30 reached)
  for (final a in state.upcomingActions) {
    print('${a.messageKey} in ${a.timeUntil}');
  }
}
```

## Testing

```bash
dart pub get
dart test
```

All times in the public API are **UTC**; the base `tz.Location` is supplied
separately and only defines where local calendar boundaries fall.
