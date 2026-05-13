# Workspace Hub — Flutter × Google Workspace

[![Analyze](https://github.com/mahmoodhamdi/flutter_google_workspace_integration/actions/workflows/analyze.yml/badge.svg)](https://github.com/mahmoodhamdi/flutter_google_workspace_integration/actions/workflows/analyze.yml)
[![Test](https://github.com/mahmoodhamdi/flutter_google_workspace_integration/actions/workflows/test.yml/badge.svg)](https://github.com/mahmoodhamdi/flutter_google_workspace_integration/actions/workflows/test.yml)
[![Build](https://github.com/mahmoodhamdi/flutter_google_workspace_integration/actions/workflows/build.yml/badge.svg)](https://github.com/mahmoodhamdi/flutter_google_workspace_integration/actions/workflows/build.yml)

Production-ready Flutter starter kit integrating Google Workspace APIs. **Same codebase ships as 5 distinct products** via Flutter flavors:

| Flavor          | Product          | Focus |
|-----------------|------------------|-------|
| `base`          | Workspace Hub    | All 7 integrations (starter kit) |
| `bizcalendar`   | BizCalendar      | Team calendar for SMBs |
| `drivevault`    | DriveVault       | Drive backup & archive |
| `sheetsops`     | SheetsOps        | Mobile dashboards from Sheets |
| `meetcompanion` | MeetCompanion    | Meeting productivity layer |

## What's included

**7 Workspace integrations** — all using SENSITIVE OAuth scopes (no CASA assessment required):

| Feature   | Scope (sensitive only)                            |
|-----------|---------------------------------------------------|
| Calendar  | `calendar` — full CRUD + recurrence + Meet links  |
| Drive     | `drive.file` + `drive.metadata.readonly`          |
| Sheets    | `spreadsheets`                                    |
| Gmail     | `gmail.send` (send-only, NO inbox read)           |
| Contacts  | `contacts`                                        |
| Maps      | API key (no OAuth)                                |
| Meet      | via Calendar `conferenceData`                     |

**Production foundation**:
- Multi-account Google Sign-In + Firebase email/password fallback
- Automatic token refresh (Dio interceptor with retry-on-401)
- Encrypted Hive cache (AES-256 keyed from secure storage)
- Sync queue for offline writes
- Riverpod state, freezed models, dartz Either errors, go_router navigation
- AR + EN localization with RTL
- Material 3 theme with per-flavor seed colors
- Biometric lock (opt-in)
- Full CI: analyze, test, build matrix per flavor, release-on-tag
- **170+ tests** (unit + widget + golden)

**Sales infrastructure**:
- 5 static landing pages (`marketing-sites/`)
- Video storyboards + social media launch copy
- 8 sales documents in `sales/` covering 3 sales models (starter kit, verticals, services)

## Quick start

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# Run the base starter kit
flutter run --dart-define=FLAVOR=base

# Or run a vertical
flutter run -t lib/main_bizcalendar.dart --dart-define=FLAVOR=bizcalendar

# Run tests
flutter test
```

## Build all 5 verticals at once

```bash
./scripts/build-all-verticals.sh
# APKs land in verticals-builds/
```

## OAuth Configuration

1. Create Google Cloud project at https://console.cloud.google.com/
2. Enable: Calendar API, Drive API, Sheets API, Gmail API, People API
3. Configure OAuth consent screen — select only SENSITIVE scopes (see `sales/OAUTH_SCOPES_EXPLAINED.md`)
4. Generate client IDs for Android/iOS/Web
5. Drop `google-services.json` into `android/app/`
6. Drop `GoogleService-Info.plist` into `ios/Runner/`
7. Set `GOOGLE_MAPS_API_KEY` via `--dart-define` if using Maps

Full publishing guide: `sales/GOOGLE_WORKSPACE_MARKETPLACE_PUBLISHING.md`

## Architecture

Clean architecture per feature (`lib/features/<feature>/`):

```
domain/       # Pure Dart entities, repository interfaces, use cases
data/         # Implementations, datasources, model mappers
presentation/ # Riverpod providers, screens, widgets
```

Core layer (`lib/core/`):
- `auth/` — multi-account OAuth + Firebase, secure token store, biometric gate
- `errors/` — AppError (freezed sealed), error mapper, guard helpers, Result type
- `network/` — Dio with auth interceptor + retry policy
- `storage/` — Hive bootstrap + sync queue + cached-read pattern
- `routing/` — GoRouter with auth-aware redirects
- `theme/` — per-flavor M3 theme derived from primary color
- `config/` — AppConfig + AppFlavor + AppFeature feature flags
- `notifications/` — local notifications + FCM (optional)

## Sales documentation

Read `sales/MASTER_PRICING.md` first for the full pricing matrix.

| Model | What | Pricing |
|-------|------|---------|
| Starter Kit | Source license | $99 / $199 / $299 |
| Vertical Products | Per-vertical license | $1K–$20K |
| Services | Integration-as-a-Service | $3K–$15K per project |

## Project status

**v1.0.0 — production ready.** See `sales/STARTER_KIT_SALES.md` for go-to-market.

## License

Commercial. See `LICENSE` (when added) — by default, single-developer use only; contact for white-label or enterprise licensing.

## Contact

- Email: hmdy7486@gmail.com
- Issues: https://github.com/mahmoodhamdi/flutter_google_workspace_integration/issues
