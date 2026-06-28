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

## Status — MVP (solo mode)

Implemented and green (`flutter analyze` clean, 53 engine tests + 5 widget tests):

- **Compliance engine** — pure Dart, EU 561/2006 + PL working time (11 counters).
- **Home screen** — large "until break" / "until end of day" countdowns, current
  state, big state buttons, level-based accent colour, disclaimer footer.
- **Notifications** — `NotificationPlanner` (tested) + `flutter_local_notifications`
  wiring (layered 30 / 15 / now alerts; delivery to be verified on a device).
- **Offline-first storage** — Drift (SQLite); activity log survives restarts.
- **History** (ewidencja), **Settings** (buffer, base time zone, language, CSV
  export, reset), **Onboarding** with disclaimer + GDPR/RODO consent gate.
- **Auto driving-detection skeleton** — confirm-after-stop prompt with backfill.
- **i18n** PL + EN from the start.

Not yet built: authentication (needs a Supabase project + Apple/Google accounts),
home-screen widget, real activity-recognition sensors, web (wasm) persistence,
and engine stage-2 (weekly rest + compensation, split daily rest, crew mode).

## Tech stack

| Concern | Choice |
| --- | --- |
| App framework | Flutter (iOS + Android; web for preview) |
| Compliance engine | Pure-Dart package `packages/compliance_engine` |
| State management | Riverpod |
| Local store (offline) | Drift (SQLite); in-memory fallback on web |
| Preferences | shared_preferences |
| Notifications | flutter_local_notifications (+ engine `NotificationPlanner`) |
| Time zones | `timezone` (DST-aware week/duty boundaries) |
| Backend (later) | Supabase |

## Repository layout

```
e_tacho/
├── packages/compliance_engine/   # pure-Dart rules engine (no Flutter/DB)
├── lib/
│   ├── main.dart
│   ├── l10n/                      # app_en.arb, app_pl.arb (+ generated)
│   └── src/
│       ├── app.dart, providers.dart, theme.dart, format.dart, ui_labels.dart
│       ├── data/                 # Drift db, repositories, preferences
│       ├── home/  history/  settings/  onboarding/
│       ├── notifications/        # service + scheduler
│       └── detection/            # driving-detection skeleton
├── docs/LEGAL_VERIFICATION.md    # defaults pending legal review + known gaps
└── test/                        # widget tests
```

## Development

### Prerequisites
- Flutter SDK (stable) — bundles Dart.

### Engine tests (pure Dart, no emulator)
```bash
cd packages/compliance_engine
dart pub get && dart test
```

### App
```bash
flutter pub get
flutter test                 # widget tests
flutter run -d chrome        # quick preview (no notifications; in-memory storage)
flutter run                  # Android device/emulator (full features)
```

### Notes
- **Notifications** require a real Android/iOS device or emulator to verify
  delivery (Android needs the notification + exact-alarm permissions already
  declared in the manifest; core-library desugaring is enabled).
- **iOS** builds require macOS/Xcode.
- After changing `lib/l10n/*.arb`, regenerate with `flutter gen-l10n`.
- After changing Drift tables, run `dart run build_runner build`.

## Compliance scope

EU 561/2006 (driving times, breaks, daily rest) + Polish Drivers' Working Time
Act (weekly working time, night-work cap, working-time break). All limits live in
a versioned **rules pack** and are treated as *defaults pending legal review* —
see [`docs/LEGAL_VERIFICATION.md`](docs/LEGAL_VERIFICATION.md).

## License

TBD.
