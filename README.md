# E-Tacho

Driver working-time assistant for professional drivers (trucks, vans). It tracks
driving time, breaks and rest periods under **EU Regulation (EC) 561/2006** and the
**Polish Drivers' Working Time Act**, warns ahead of limits, and reminds about
mandatory breaks via on-device notifications.

> ⚠️ **Disclaimer / Zastrzeżenie**
>
> This app is a **supporting tool only**. The legal source of truth is the
> tachograph. E-Tacho does **not** relieve the driver or operator of legal
> responsibility and does **not** guarantee regulatory compliance.
>
> Aplikacja jest **narzędziem pomocniczym**. Źródłem prawdy jest tachograf.
> Nie zwalnia z odpowiedzialności prawnej i nie gwarantuje zgodności z przepisami.

## Status

Early development — building the MVP. Per the project plan, the **compliance rules
engine is implemented first**, as a pure-Dart, fully unit-tested package, before any
UI is built.

## Guiding principles

1. **Driver's ally, not surveillance** — works for the driver, not the employer.
2. **A helper, not the source of truth** — the tachograph is the legal record.
3. **Minimal interaction while driving** — key actions happen before/after driving.
4. **Offline-first** — all counting and notifications work fully offline.
5. **Rules are configuration, not code** — limits live in a versioned rules pack.

## Tech stack

| Concern | Choice |
| --- | --- |
| App framework | Flutter (iOS + Android) |
| Compliance engine | Pure-Dart package (`packages/compliance_engine`), no Flutter deps |
| Local store (offline) | Drift (SQLite) |
| State management | Riverpod |
| Backend / auth / sync | Supabase (optional, async) |
| Notifications | flutter_local_notifications (on-device scheduled) |

## Repository layout

```
e_tacho/
├── packages/
│   └── compliance_engine/   # pure Dart — the rules engine (no Flutter/DB)
├── lib/                      # Flutter app (UI, data, services)
├── test/                    # app-level tests
└── melos.yaml               # workspace
```

## Development

### Prerequisites

- Flutter SDK (stable channel) — bundles the Dart SDK.

### Run the engine tests (pure Dart, no emulator)

```bash
cd packages/compliance_engine
dart pub get
dart test
```

### Run the app

```bash
flutter pub get
flutter run
```

## Compliance scope

- EU Regulation (EC) 561/2006 — driving times, breaks, daily rest.
- Polish Drivers' Working Time Act — working-time limits, night-work limit.

Regulatory limits live in a **versioned rules pack** and are treated as *defaults
pending legal review*. Points needing confirmation are marked in code with
`// TODO: zweryfikować z przepisami`.

## License

TBD.
