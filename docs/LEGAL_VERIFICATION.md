# Legal verification checklist

E-Tacho is a **supporting tool**. The legal source of truth is the tachograph.
The values and interpretations below are **defaults pending review by a lawyer /
transport-compliance specialist**. Nothing here should be presented to drivers
as a guarantee of compliance.

All limits live in the versioned `RulesPack` (`compliance_engine`) and can be
changed server-side without an app update. Defaults are in `RulesPack.defaultEuPl`.

## 1. Default limit values to confirm

Confirm every value against the current consolidated text of EU Regulation (EC)
561/2006 and the Polish *ustawa o czasie pracy kierowców*.

| Item | Default | Reference (to verify) |
| --- | --- | --- |
| Continuous driving before break | 4h30 | 561/2006 art. 7 |
| Required break | 45 min (or 15 + 30) | 561/2006 art. 7 |
| Daily driving | 9h | 561/2006 art. 6(1) |
| Extended daily driving | 10h, max 2×/week | 561/2006 art. 6(1) |
| Daily rest — regular / reduced | 11h / 9h | 561/2006 art. 8(2),(4) |
| Reduced daily rests between weekly rests | max 3 | 561/2006 art. 8(4) |
| Split daily rest (first part) | 3h, then 9h | 561/2006 art. 8(2) |
| Weekly rest — regular / reduced | 45h / 24h | 561/2006 art. 8(6) |
| Weekly rest window (6×24h) | 144h | 561/2006 art. 8(6) |
| Reduced weekly rests per fortnight | max 1 | 561/2006 art. 8(6) |
| Weekly driving | 56h | 561/2006 art. 6(2) |
| Two-week driving | 90h | 561/2006 art. 6(3) |
| Duty window (solo) | 24h | 561/2006 art. 8(2) |
| Weekly working time (PL) | 60h single week | PL act art. 12 |
| Avg weekly working time (PL) | 48h / reference period | PL act art. 12 |
| Reference period (averaging) | 17 weeks (~4 months) | PL act art. 12 |
| Night-work working-time cap (PL) | 10h per duty | PL act art. 21 |
| Working-time break (PL) | 30 min after 6h work; 45 min if >9h | PL act art. 13 |

## 2. Open interpretation questions (marked `// TODO: zweryfikować` in code)

1. **Night window ("pora nocna").** PL law defines night as a 4-hour span set by
   the employer within 00:00–07:00. Default used: **00:00–04:00**. Confirm the
   span and whether it is configurable per employer.
   (`rules_pack.dart`, `night_work_counter.dart`)
2. **Duty window — start vs completion.** We treat the 24h window as satisfied if
   the new daily rest **starts** before it closes. Confirm whether the rest must
   be *completed* within 24h. (`duty_window_counter.dart`)
3. **Weekly-rest boundary for reduced-rest counting.** "Between weekly rests" is
   detected via a rest of ≥ 24h (`weeklyRestReduced`). Confirm this proxy until
   full weekly-rest tracking lands. (`reduced_daily_rests_counter.dart`)
4. **Week assignment of extended driving days.** An extended (10h) day is counted
   in the ISO week of the daily driving period's **start**. Confirm.
   (`extended_driving_days_counter.dart`)
5. **Working-time definition.** Working time = driving + other work; availability
   is excluded. Confirm the treatment of availability / waiting time under PL law.
6. **PL working-time break (art. 13).** Implemented as: a break is due after 6h of
   *consecutive* work; the required total is 30 min if daily work ≤ 9h, otherwise
   45 min; splittable into ≥15-min parts; EU 561/2006 breaks count (any rest
   accrues toward it and resets the clock). Confirm: "consecutive" vs cumulative
   basis, the 9h threshold basis (daily working time), and part accumulation.
   (`working_time_break_counter.dart`)
7. **Split daily rest (art. 8(2)).** A 9–11h rest is treated as the *regular*
   second part of a split (and so not a reduced rest) when a ≥3h rest preceded it
   earlier in the same day. Confirm the detection (first part 3h..<9h, second
   part ≥9h, driving allowed between). (`reduced_daily_rests_counter.dart`)
8. **Weekly rest + compensation (art. 8(6)-(9)).** Implemented: the 6×24h window
   to start the next weekly rest, max one reduced weekly rest per two consecutive
   weeks, and an *informational* outstanding-compensation total (gross reductions
   over ~3 weeks). NOT yet enforced: the exact compensation deadline (end of the
   third following week). Compensation is now netted against excess rest beyond
   45h (a simplification — confirm it, and the "attached en bloc to a ≥9h rest"
   rule is still TODO). (`weekly_rest_counter.dart`,
   `reduced_weekly_rests_counter.dart`, `weekly_rest_compensation_counter.dart`)
9. **48h average working time (PL art. 12).** Modelled as a cap on total working
   time over the last `referencePeriodWeeks` ISO weeks (rolling): total ≤ 48h ×
   weeks. Confirm the reference-period length (4 vs 6 months) and the
   fixed-vs-rolling semantics. (`average_weekly_working_time_counter.dart`)

## 3. Known gaps (not yet implemented — by design, MVP)

- **Crew / multi-manning**: the 30h duty window is implemented (`DutyMode.crew`).
  The availability-as-break nuance (passenger time counting as a break) and
  dual-device sync are not yet done.
- **Ferry/train, AETR** rules. Out of scope.

## 4. Required product disclaimers

- First-run onboarding must show the "supporting tool, not a legal guarantee"
  disclaimer and capture consent (GDPR/RODO).
- A persistent disclaimer must be visible in the home-screen footer.
- Never phrase notifications/messages as a guarantee of compliance.
