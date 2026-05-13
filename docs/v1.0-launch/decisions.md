# Strategic Decisions Log

## D1 — Drop Google Docs from scope (2026-05-13)
**Decision**: Remove `lib/features/google_docs/` from production scope.
**Reason**: Google Docs has a complex document model (StructuralElement, ParagraphElement, TextRun, etc.) that does not map cleanly to mobile. A useful mobile Docs editor would compete head-on with Google's own Docs app and lose. The API is best suited to programmatic doc generation, not interactive editing — outside this product's value proposition.
**Where used**: Reference in `OAUTH_SCOPES_EXPLAINED.md` and `STARTER_KIT_SALES.md` as "intentionally excluded."

## D2 — Drop Google Keep from scope (2026-05-13)
**Decision**: Remove `lib/features/google_keep/`. **Do not implement.**
**Reason**: Google Keep has no official public API. The "Keep API" exists as an internal/enterprise-only endpoint that requires a Google Workspace Admin to enable for the organization. Community libraries reverse-engineer the web UI's XHR endpoints and break with every Google rollout. Shipping Keep would create permanent maintenance debt with zero quality floor.

## D3 — Drop Google Analytics from scope (2026-05-13)
**Decision**: Remove `lib/features/google_analytics/` from primary product. Mark as optional add-on for the services tier.
**Reason**: Analytics consumers are desktop users (marketers, data analysts) building dashboards in a wide display. Mobile is the wrong form factor. The audience that wants Analytics on mobile is small enough that competing with Google Analytics' own apps (Looker, GA mobile) is not winnable. Better as a service-tier custom integration for clients who specifically request it.

## D4 — Gmail scope restricted to `gmail.send` only (2026-05-13)
**Decision**: Implement Gmail as **send-only** via the `gmail.send` scope.
**Reason**: Reading user mail (`gmail.readonly`, `gmail.modify`, `mail.google.com`) requires Google CASA assessment ($15K-75K + 3-6 months) before publishing on Workspace Marketplace. The `gmail.send` scope is **sensitive only**, requiring just brand verification (1-2 months). This decision constrains 100% of the marketability of the Gmail feature to compose-and-send workflows, but eliminates the largest financial and time blocker from the product's roadmap.
**Caveat**: Buyers who need full Gmail can elect to pay CASA themselves on a fork; we document this path in `OAUTH_SCOPES_EXPLAINED.md`.

## D5 — Drive scope restricted to `drive.file` + `drive.metadata.readonly` (2026-05-13)
**Decision**: Use only `drive.file` (per-file, app-created) and `drive.metadata.readonly`. **Avoid full `drive` scope.**
**Reason**: Full `drive` scope is restricted; CASA-required. `drive.file` is the most-restrictive Drive scope — apps see only files they create or that the user explicitly opens with the app. This is sufficient for DriveVault (backup app's own folder) and for any vertical that creates its own working set. Cannot scan the user's entire Drive — but this is not a real limitation for any of our vertical products.
**Trade-off documented in**: `OAUTH_SCOPES_EXPLAINED.md`.

## D6 — State management: migrate from flutter_bloc to flutter_riverpod (2026-05-13)
**Decision**: Replace `flutter_bloc` with `flutter_riverpod` as the sole state management library.
**Reason**: bloc requires more boilerplate (Cubit/Bloc + State + Event + BlocBuilder + BlocProvider), and the existing codebase started but never completed a calendar cubit. Riverpod 2.x (`AsyncNotifier`, `AutoDisposeAsyncNotifierProvider`) is more compact, has compile-time-safe DI, supports `family` providers (per-account, per-id scoping), and integrates cleaner with `freezed` sealed errors. The fact that the codebase has near-zero bloc code already means migration cost is essentially zero (we are writing from scratch either way).

## D7 — State persistence: Hive Flutter (2026-05-13)
**Decision**: Use `hive_flutter` for offline cache (not sqflite, not drift, not isar).
**Reason**: Hive is in-memory-fast, supports type adapters (compatible with freezed), supports AES-256 encryption out of the box (`HiveAesCipher`) using a key stored in `flutter_secure_storage`. SQLite-based alternatives (sqflite, drift) require schema migration management we do not need for cache-only data. Isar v3 is being deprecated in favor of v4 which is unstable.

## D8 — Codegen stack: freezed + json_serializable (2026-05-13)
**Decision**: All domain entities and data models use `freezed` (immutability + copyWith + equality + sealed unions) + `json_serializable` (JSON).
**Reason**: Standard Flutter community choice. Sealed unions allow modelling errors as `sealed class AppError = NetworkError | AuthError | QuotaError | ...` enabling exhaustive `when()`/`map()` on the UI side. Boilerplate-free model code reduces review surface area.

## D9 — Auth split: Google Sign-In + Firebase Email/Password (2026-05-13)
**Decision**: Two parallel auth paths:
  1. **Google Sign-In** — primary, used to obtain OAuth access tokens for Workspace APIs.
  2. **Firebase Auth (email/password)** — secondary, for users who want to register without a Google account but still use a limited feature set (Maps, local notes, etc.).
**Reason**: A pure Google-Sign-In app excludes potential buyers; a pure email/password app cannot access Workspace APIs. Supporting both with a clear UX delineation (some features grayed out without Google linkage) maximizes addressable market.

## D10 — Package name kept as `google_apis_flutter` (2026-05-13)
**Decision**: Do NOT rename the pubspec `name:` field.
**Reason**: All existing imports use `package:google_apis_flutter/...`. Renaming would require touching ~30 files for zero functional benefit. The rebranding for sales happens at the vertical-flavor level (app display name, bundle id) — the underlying Dart package name is invisible to end users.

## D11 — Verticals as Flutter flavors, not separate apps (2026-05-13)
**Decision**: 4 verticals (BizCalendar, DriveVault, SheetsOps, MeetCompanion) live in one repo as **flavor configs** sharing the core codebase, with feature-flag gating, distinct app icons, app names, bundle ids, and entry points (`main_bizcalendar.dart`, etc.).
**Reason**: Maintaining 4 forked Flutter apps in parallel is operationally infeasible. The flavor pattern lets us:
  - Share 95% of code.
  - Ship vertical-specific UX/branding.
  - Build each independently (`flutter build apk --flavor bizcalendar -t lib/main_bizcalendar.dart`).
  - License the entire codebase as a starter kit (Model 1) **and** sell verticals as packaged products (Model 2) from the same source — buyers get value either way.

## D12 — No fields validation that the existing build will compile (2026-05-13)
**Decision**: Acknowledge that the existing `test/widget_test.dart` references `MyApp()` with a parameter signature it no longer has. Will be deleted and replaced as part of the test-suite phase.
**Reason**: It is a relic of `flutter create` template, never updated.

## D13 — Local toolchain absent → all validation in CI (2026-05-13)
**Decision**: Trust GitHub Actions Ubuntu runners for `flutter analyze` / `flutter test` / `flutter build`. Do not attempt local Flutter install (would require sudo + ~1GB download + ~20 minutes; CI does this in a controlled environment with `subosito/flutter-action`).
**Reason**: Production projects validate in CI as a matter of policy anyway. The fact that the local box is bare is incidental.

## D14 — Marketing screenshots generated by golden test infrastructure (2026-05-13)
**Decision**: Instead of hand-crafting 160 screenshots, write a `screenshots_test.dart` that runs golden_toolkit to render all main screens in 4 variants (light/dark × AR/EN) at multiple device sizes, then commits the PNG outputs to `marketing/screenshots/<vertical>/`.
**Reason**: Programmatic generation is reproducible (regenerable on every release), translates automatically when text changes, and scales linearly with the number of screens without manual effort. The output quality matches the real app rendering pixel-for-pixel.

## D15 — Landing pages as static HTML committed to repo (2026-05-13)
**Decision**: Build 5 landing pages as plain HTML+CSS in `marketing-sites/<vertical>/index.html`, deployable to Vercel via the included `vercel.json` per directory.
**Reason**: No framework (Next.js, Nuxt, etc.) needed for sales sites — they have no auth, no DB, no realtime. Static HTML loads instantly, has zero build steps for the buyer, and a buyer can fork the landing page and white-label in 10 minutes.
