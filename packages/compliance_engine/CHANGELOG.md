## 0.1.0

Initial compliance engine (MVP, solo mode).

- Value models: `ActivityEvent`, `RulesPack` (EU 561/2006 + PL fields, JSON
  parsing + validation), `CounterStatus`, `RequiredAction`, `Violation`,
  `ComplianceState`.
- `ActivityTimeline`: normalises events into intervals (the state machine).
- Counters: continuous driving (45m + 15/30 split), daily driving (9h/10h),
  extended driving days (2/week), duty window (24h solo), daily rest (11h/9h),
  reduced daily rests (3 between weekly rests), weekly driving (56h),
  fortnightly driving (90h), PL weekly working time (60h), PL night work (10h),
  PL working-time break (30/45 min after 6h, art. 13).
- `ComplianceEngine.evaluate(...)`: pure aggregator returning `ComplianceState`.
- `NotificationPlanner`: projects a `ComplianceState` into a cancellable set of
  local notifications (lead-time limit alerts + may-resume-work).
- Split daily rest (3h + 9h, art. 8(2)) recognised as a regular rest, so it does
  not consume a reduced daily-rest allowance (`RulesPack.dailyRestSplitFirst`).
- 55 unit tests (happy-path + violation per rule, RulesPack parsing,
  time-zone + midnight crossing, duty reset, notification planning, split rest).

All limits are defaults pending legal review — see `docs/LEGAL_VERIFICATION.md`.
