# Initial Code Audit — flutter_google_workspace_integration

**Audit date**: 2026-05-13
**Repo**: github.com/mahmoodhamdi/flutter_google_workspace_integration
**Default branch**: main
**Total Dart files**: 117 (1,511 LOC)
**Last meaningful commit**: c093c40 ("feat: Setup project structure with clean architecture and dependency injection")

---

## Executive Verdict

The repository is **scaffolding only**. Of the 117 Dart files, the majority are zero-byte empty files placed where Clean Architecture would expect them (entities, models, repositories, datasources, usecases). The actual implementation lines (~1,500 LOC) are concentrated entirely in:

- `lib/core/utils/` (themes, validators, helpers, formatters, sizes, colors, logger) — **production-grade**
- `lib/features/home/presentation/pages/home_page.dart` — navigation grid (working)
- `lib/main.dart` + `lib/app.dart` — minimal app boot

**Every Google Workspace integration file is empty.** The README's 10 promised integrations have 0 functional code.

This is **not a polish job** — it is a **build-from-zero** job using the existing folder structure as a contract.

---

## Google Workspace Integrations

| Service        | Status   | LOC | Quality      | Notes |
|----------------|----------|-----|--------------|-------|
| Calendar       | missing  | 0   | empty stubs  | entity, model, repo, datasource, usecases all 0 bytes. Has cubit/state files that are also 0 bytes. |
| Drive          | missing  | 0   | empty stubs  | Same — full Clean Arch folder tree, all files empty. |
| Docs           | missing  | 0   | empty stubs  | Will be **dropped** from scope (weak ROI vs competing with Google Docs app). |
| Sheets         | missing  | 0   | empty stubs  | Same scaffolding pattern. |
| Keep           | missing  | 0   | empty stubs  | Will be **dropped** — no official public API exists; only unofficial reverse-engineered libraries that break frequently. |
| Gmail          | missing  | 0   | empty stubs  | Will be **scoped to send-only** via `gmail.send` (sensitive) — avoid `gmail.modify`/full mailbox (restricted, requires CASA). |
| Analytics      | missing  | 0   | empty stubs  | Will be **dropped** — mobile is wrong form factor for analytics; market is small. |
| Maps           | missing  | 0   | empty stubs  | Will be implemented as reusable widget (API-key based, no OAuth). |
| Meet           | missing  | 0   | empty stubs  | Implemented via Calendar API `conferenceData` (no standalone Meet API exists publicly). |
| Contacts       | missing  | 0   | empty stubs  | Will use People API with `contacts` scope (sensitive). |

**In-scope after this audit (7 features)**: Calendar, Drive, Sheets, Gmail (send), Contacts, Maps, Meet
**Dropped (3 features)**: Docs, Keep, Analytics — documented in `decisions.md`.

---

## Authentication

| Component        | Status   | Notes |
|------------------|----------|-------|
| Firebase Auth    | missing  | No firebase_core/auth deps in pubspec. No Firebase config. |
| Google OAuth     | missing  | Has `extension_google_sign_in_as_googleapis_auth` dep but no implementation. |
| Token refresh    | missing  | No token storage. |
| Multi-account    | missing  | Not designed. |
| Secure storage   | missing  | No `flutter_secure_storage` dep. |
| Biometric lock   | missing  | No `local_auth` dep. |

**All of the auth foundation must be built.**

---

## Architecture

| Aspect                          | Status      | Notes |
|---------------------------------|-------------|-------|
| Folder structure compliance     | 100%        | Clean Architecture layout present (data/domain/presentation) per feature. |
| Domain layer pure Dart          | n/a         | All files empty. |
| State management                | partial     | `flutter_bloc` declared as dep; one zero-byte cubit/state file in calendar. **No working cubit.** |
| Repository pattern              | n/a         | All `*_impl.dart` are empty. |
| Dependency injection            | empty       | `get_it` is a dep; `service_locator.dart` is empty (0 bytes). |
| Error handling                  | n/a         | `dartz` is a dep (for `Either<L,R>`) but never used. |
| Routing                         | minimal     | `home_page.dart` uses `Navigator.push` directly with `MaterialPageRoute`. No go_router. |
| i18n                            | none        | `intl` is a dep but no ARB files, no localization delegate. |
| Logging                         | basic       | `logger` package configured in `core/utils/logger/logger.dart` (working). |

---

## Tests

| Type         | Count | Coverage |
|--------------|-------|----------|
| Unit         | 0     | 0% |
| Widget       | 1     | trivial (default `test/widget_test.dart`, references a `MyApp()` constructor signature that no longer matches — would fail compile). |
| Golden       | 0     | 0% |
| Integration  | 0     | 0% |
| **Total**    | **1** | **0% effective** |

The single test file is the boilerplate Flutter creates with `flutter create` — it has **never been updated** and references a non-existent counter app. It will not compile against the current `app.dart`.

---

## Dependencies (current `pubspec.yaml`)

**Present**:
- `connectivity_plus: ^6.0.3`
- `cupertino_icons: ^1.0.6`
- `dartz: ^0.10.1` (unused)
- `dio: ^5.5.0+1`
- `equatable: ^2.0.5`
- `extension_google_sign_in_as_googleapis_auth: ^2.0.12`
- `flutter_bloc: ^8.1.6`
- `get_it: ^7.7.0` (unused — service_locator empty)
- `googleapis: ^13.2.0`
- `googleapis_auth: ^1.6.0`
- `intl: ^0.19.0`
- `logger: ^2.4.0`
- `url_launcher: ^6.3.0`

**Missing for production**:
- `google_sign_in` (the actual sign-in package; the extension dep alone is insufficient)
- `firebase_core` + `firebase_auth`
- `flutter_secure_storage` (token storage)
- `hive_flutter` + `hive` (offline cache)
- `flutter_riverpod` (or commit to bloc — pubspec has bloc but we'll migrate)
- `freezed` + `freezed_annotation` + `json_annotation` + `json_serializable` (immutable models + JSON)
- `build_runner` (codegen)
- `mocktail` (test mocking)
- `golden_toolkit` (golden tests)
- `local_auth` (biometric)
- `local_auth_android` + `local_auth_darwin` (platform impls)
- `flutter_local_notifications` (reminders)
- `firebase_messaging` (FCM push)
- `cached_network_image`
- `image_picker` + `file_picker` (Drive upload)
- `retry` (transient errors)
- `path_provider`
- `flutter_localizations` SDK + ARB tooling

**Dependency name issue**: The package is named `google_apis_flutter` in `pubspec.yaml` (note plural "apis") and imports use `package:google_apis_flutter/...`. We'll keep this name to avoid touching every import statement.

---

## OAuth Scope Strategy (Critical for Marketability)

To avoid Google's **CASA security assessment** ($15K-75K + 3-6 months wait), we must use only **sensitive** scopes (brand verification only, 1-2 month review).

### Restricted scopes — **DO NOT USE** (would require CASA):
- `https://mail.google.com/` (full Gmail)
- `https://www.googleapis.com/auth/gmail.modify`
- `https://www.googleapis.com/auth/gmail.readonly`
- `https://www.googleapis.com/auth/drive` (full Drive)

### Sensitive scopes — **safe to use** (brand verification):
- `https://www.googleapis.com/auth/calendar` (events read/write)
- `https://www.googleapis.com/auth/calendar.events`
- `https://www.googleapis.com/auth/calendar.readonly`
- `https://www.googleapis.com/auth/drive.file` (per-file, app-created)
- `https://www.googleapis.com/auth/drive.metadata.readonly`
- `https://www.googleapis.com/auth/spreadsheets`
- `https://www.googleapis.com/auth/spreadsheets.readonly`
- `https://www.googleapis.com/auth/contacts`
- `https://www.googleapis.com/auth/contacts.readonly`
- `https://www.googleapis.com/auth/gmail.send` (compose-and-send only — does NOT grant read)

### Non-OAuth (API key only):
- Maps SDK / Geocoding / Places (Google Maps Platform — has its own billing model, no consent screen)

**Result**: A buyer can publish to Workspace Marketplace and pass review **without CASA cost** by using this scope subset.

---

## Build & Tooling Status (Local Machine)

| Tool         | Available | Version |
|--------------|-----------|---------|
| Flutter      | **No**    | not installed |
| Dart         | **No**    | not installed (Flutter bundles Dart) |
| Java         | **No**    | not installed |
| adb          | **No**    | not installed |
| gh CLI       | Yes       | 2.92.0 |
| Disk free    | Yes       | 768 GB |
| Memory free  | Yes       | 11 GB |

**Implication**: Local `flutter analyze`, `flutter test`, `flutter build` cannot run. **All validation will occur in GitHub Actions** (Ubuntu runners with Flutter pre-installable). The code we write must be self-validating via CI. This is acceptable — production codebases are validated in CI anyway.

---

## What Must Be Built (Scope of Work)

1. **Pubspec**: Add ~25 dependencies. Add flavor support.
2. **Foundation layer**: error types (freezed sealed), result type, logger, secure storage, network client with auth interceptor.
3. **Auth**: full multi-account OAuth + Firebase email/password + biometric lock + token refresh + scope expansion.
4. **7 integrations**: Calendar, Drive, Sheets, Gmail send, Contacts, Maps, Meet — each with domain (entity + repo iface + usecases), data (model + datasource + repo impl + cache), presentation (providers + screens).
5. **Offline cache layer**: Hive boxes per integration, sync queue, conflict resolution.
6. **i18n**: AR/EN ARB files, RTL support, all user-visible strings extracted.
7. **Tests**: 200+ unit + widget + golden + integration.
8. **CI**: 4 workflows (analyze, test, build matrix, release).
9. **Verticals**: 4 flavor configs (bizcalendar, drivevault, sheetsops, meetcompanion) + entry points + feature flags + build scripts.
10. **Marketing**: 5 landing-page HTML sites + screenshot generation infra (via golden tests) + video storyboards + social copy.
11. **Sales docs**: 8 documents in `sales/`.
12. **Final**: ~25 commits, PR, release.

**Estimated LOC delta**: from 1,511 → ~25,000-35,000 LOC of new application code + ~12,000 LOC of tests + ~8,000 LOC of marketing/sales/docs.

---

## Decision Summary

- Drop: Docs, Keep, Analytics (documented in decisions.md).
- Migrate state mgmt: `flutter_bloc` → `flutter_riverpod` (lighter, more flexible, better DX).
- Keep package name: `google_apis_flutter` (avoids touching every import).
- State persistence: `hive_flutter` (faster than sqflite for our use cases, encryption support).
- Codegen: `freezed` + `json_serializable` (immutability + safer JSON).
- Auth strategy: Google Sign-In + Firebase auth in parallel (Google for workspace, Firebase for email/pw fallback).
- All OAuth scopes: **sensitive only**, zero restricted.

End of audit.
