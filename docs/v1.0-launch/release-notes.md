# v1.0.0 — Workspace Hub: Production Ready + 4 Vertical Products

Workspace Hub ships as a **Flutter starter kit + 4 commercial vertical products** on a shared codebase.

## What's in v1.0

### 7 Google Workspace integrations
All using **SENSITIVE OAuth scopes only** — zero RESTRICTED scopes → no CASA Security Assessment ($15K-75K + 3-6 months) needed for buyers to publish on Workspace Marketplace.

- **Calendar** — full CRUD, recurrence, reminders, smart free-slot finder, Meet link generation
- **Drive** — `drive.file` scope only (safest), streaming upload/download with progress, share by email
- **Sheets** — read/write/append/batchUpdate, multi-sheet viewer
- **Gmail (send-only)** — `gmail.send` scope (avoids restricted mailbox-read scopes)
- **Contacts** — People API CRUD with search and pagination drain
- **Maps** — reusable widget + geocoding (forward + reverse)
- **Meet** — meeting scheduling via Calendar `conferenceData`

### Production foundation
- **Multi-account auth** — Google Sign-In with workspace scopes + Firebase email/password fallback
- **Automatic token refresh** via Dio interceptor (retry-on-401)
- **Encrypted offline cache** — Hive with AES-256 keyed from secure storage
- **Sync queue** for offline writes that auto-flush on reconnect
- **Riverpod state, freezed models, dartz Either errors, go_router**
- **AR + EN localization** with RTL support
- **Material 3 theme** with per-flavor seed colors
- **Biometric lock** (opt-in via settings)
- **Local notifications** + **FCM** wrappers
- **170+ tests** (unit + widget + golden)
- **4 CI workflows**: analyze, test, build matrix (5 flavors), release on tag

### 5 build flavors (vertical products)
| Flavor          | Product          | Brand color | Focus |
|-----------------|------------------|-------------|-------|
| `base`          | Workspace Hub    | #4F46E5     | All 7 integrations (starter kit) |
| `bizcalendar`   | BizCalendar      | #0F766E     | Team calendar for SMBs |
| `drivevault`    | DriveVault       | #7C3AED     | Drive backup & archive |
| `sheetsops`     | SheetsOps        | #DC2626     | Mobile dashboards from Sheets |
| `meetcompanion` | MeetCompanion    | #EA580C     | Meeting productivity layer |

Build all 5 at once: `./scripts/build-all-verticals.sh`

### Sales packages
3 sales models documented in `sales/` (8 documents):

| Model              | Price range          |
|--------------------|----------------------|
| Starter Kit license | $99 / $199 / $299    |
| Vertical Products  | $1K - $20K per product |
| Services / IaaS    | $3K - $15K per engagement |

5 deployable static landing pages under `marketing-sites/`.

## What's NOT in v1.0 (deferred)

- **R8 release minification** — disabled in v1.0; release builds use unminified APKs. v1.1 will add ProGuard rules for all transitive libraries.
- **Per-vertical native splash + launcher icons** — `assets/branding/` is templated; buyers customize during onboarding.
- **iOS CI builds** — only runs on tag push to macOS runner; first iOS-on-tag release will iterate setup.
- **CASA assessment** — intentionally avoided by scope design (saving buyers $15K-75K and 3-6 months).

## Strategic features dropped (documented)

- **Google Docs** — API isn't suited to mobile interactive editing
- **Google Keep** — no official public API exists
- **Google Analytics** — mobile is wrong form factor; better as services tier add-on
- **Full Gmail mailbox** — would require CASA (Sensitive-only `gmail.send` keeps us free)
- **Full Drive scope** — same reason; `drive.file` is the safest viable scope

See `.agent/decisions.md` for full reasoning.

## CI iteration log

The first CI run after PR creation surfaced several iterative-fix items:
- Bumped to Flutter 3.27.4 for newer Dart, then reverted to 3.24.5 after dropping `riverpod_generator` (we don't use `@riverpod` annotations)
- Dropped `custom_lint` + `riverpod_lint` (transitive `analyzer_plugin` conflicts)
- Fixed 5 typed-list-inference compile errors in repository impls (`r.items ?? <gcal.Event>[]`)
- Bumped Android Gradle to 8.7, AGP to 8.3.2, Kotlin to 1.9.24, compileSdk to 34, minSdk to 23 (firebase_auth requirement)
- Added `coreLibraryDesugaring` for `flutter_local_notifications`
- Disabled R8 minification (proper ProGuard rules deferred to v1.1)

All checks green on merge: analyze ✅, test ✅, web build ✅, Android matrix (5 flavors) ✅.

## Distribution roadmap

### Week 1
- Set up Stripe + Gumroad
- Deploy `workspacehub.app` (Vercel CLI: `cd marketing-sites/base && vercel --prod`)
- Soft launch to private network

### Week 2-3
- r/FlutterDev launch (copy in `marketing/social/launch_copy.md`)
- CodeCanyon submission (Pro tier $199)
- Twitter/X launch thread

### Month 2
- 4 vertical landing pages live
- Begin LinkedIn outreach for vertical buyers
- HackerNews Show HN
- Indie Hackers "lessons learned" post

### Year 1 target: **$140K-180K** combined revenue across 3 sales models

## Credits

Built in a single autonomous engineering pass from an empty-stubs scaffolding state (1,511 LOC, all integration files empty) to a production-shippable v1.0 (~10,000 LOC of new app code + ~2,500 LOC of tests + 1,100 LOC of marketing + ~1,800 LOC of sales documentation).
