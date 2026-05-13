# Social Media Launch Copy

## Twitter / X

### Launch announcement
> 🚀 Shipping Workspace Hub v1.0 — a production-ready Flutter starter kit for Google Workspace.
>
> 7 integrations · multi-account OAuth · offline-first cache · 170+ tests · CI for 5 build flavors.
>
> Uses SENSITIVE OAuth scopes only — so you can publish without the $15K+ CASA assessment.
>
> 👉 workspacehub.app
> #FlutterDev #GoogleWorkspace

### Thread: "Why we built it"
> 🧵 1/7 Why I built Workspace Hub instead of just hacking together google_sign_in + a few API calls:
>
> 2/7 Every Workspace integration I've shipped has had the same 200 hours of "boring" setup: multi-account, token refresh, scope expansion, offline cache, error mapping, retry policies.
>
> 3/7 And every single time, the *Google Workspace Marketplace review* turned a 2-week ship into a 4-month wait. Especially for anything touching Gmail or full-Drive.
>
> 4/7 So I made a rule: ZERO restricted scopes. Use gmail.send not gmail.modify. Use drive.file not drive. Result: brand verification only, no CASA, no $15K-75K fee.
>
> 5/7 Then I made the same call again at the product level. Don't sell "Workspace App". Sell 4 verticals: BizCalendar, DriveVault, SheetsOps, MeetCompanion. Same codebase, 5 flavor configs.
>
> 6/7 v1.0 ships today. 35,000+ lines of code I'd rather not write twice. Yours for $99-299 or as a starter for a $5K-20K vertical product.
>
> 7/7 → workspacehub.app

### BizCalendar feature spotlight
> 📅 BizCalendar's smart slot finder respects each teammate's working hours AND time zone. The algorithm walks busy/free windows in 15-min steps and snaps to working bounds.
>
> Source code, including unit tests for the algorithm, at bizcalendar.app
> #FlutterDev #GoogleCalendar

### DriveVault privacy talking point
> 🔒 DriveVault uses ONLY `drive.file` scope. That means it can literally see only files it created or that you explicitly opened with it. Google Drive can't be scanned, even if we wanted to.
>
> drivevault.app — $1,500 self-hosted, $4,500 white-label.

## LinkedIn

### Launch post
> I just shipped Workspace Hub v1.0 — a Flutter starter kit + 4 vertical products built on the same codebase, integrating Google Workspace APIs.
>
> Why this matters for B2B:
>
> • **One codebase, four products.** BizCalendar (smart team calendar), DriveVault (Drive backup), SheetsOps (mobile dashboards), MeetCompanion (Meet productivity). Flutter flavors handle the per-vertical branding/feature flags.
>
> • **Zero restricted OAuth scopes.** Built so any buyer can publish on Workspace Marketplace via brand verification alone — no $15K-75K CASA Security Assessment, no 3-6 month wait.
>
> • **Production-grade foundations.** Multi-account auth, secure token storage (Keychain/Keystore), automatic refresh, offline-first with AES-256 cache, sync queue for offline writes, exponential-backoff retry, 170+ tests, full CI matrix.
>
> Pricing tiers from $99 (single-developer starter) to $20K (enterprise white-label).
>
> If you're building a productivity app on Google Workspace, this saves 200+ hours of boring infrastructure. → workspacehub.app

### Vertical product post (BizCalendar example)
> For mid-size remote teams: BizCalendar is now in production.
>
> Three features I think matter most:
> 1. **Working hours per teammate** — the slot finder respects them. No more 2 AM invites.
> 2. **Meeting cost calculator** — gives finance a number to push against meeting bloat.
> 3. **Time zone display** — every event shows in the viewer's TZ AND each attendee's TZ.
>
> Self-hosted source from $1,500. White-label from $4,500. Enterprise from $15K.
>
> bizcalendar.app

## Reddit r/FlutterDev

### Launch thread
**Title**: [Showcase] Workspace Hub v1.0 — production Flutter starter kit for Google Workspace (7 APIs, multi-account, offline-first)

**Body**:
Hey r/FlutterDev,

After three months of work I'm shipping Workspace Hub v1.0 — a starter kit for Flutter apps that integrate with Google Workspace.

**What's in it (and tested)**:
- 7 integrations: Calendar (full CRUD + recurrence + Meet links), Drive (drive.file scope), Sheets (read/write/append/batch), Gmail (send-only), Contacts (People API), Maps + geocoding, Meet via Calendar
- Multi-account auth with Google Sign-In + Firebase email/pw fallback
- Automatic token refresh via Dio interceptor (retry on 401 after refresh)
- Encrypted Hive cache (AES-256 keyed from secure storage)
- Sync queue for offline writes that auto-flushes when connectivity returns
- Riverpod state, freezed entities, dartz Either for errors, go_router navigation
- 170+ tests (unit + widget + golden)
- AR + EN localization with RTL
- CI: analyze, test, build matrix (5 flavors), release-on-tag
- 5 Flutter flavors: base + 4 commercial verticals

**Key design decisions** (would love feedback on these):
- Dropped Google Docs, Google Keep, Google Analytics — Docs because mobile editing competes with Google's own app, Keep because there's no official public API, Analytics because mobile is the wrong form factor
- Hard rule: zero restricted OAuth scopes — uses gmail.send not gmail.modify, drive.file not drive. Means buyers can publish via brand verification alone (1-2 months) instead of CASA ($15K-75K + 6 months)
- Verticals are flavor configs not separate apps — share 95% of code, build with `flutter build apk --flavor bizcalendar -t lib/main_bizcalendar.dart`

License is $99-299 for the source. Or, if you want, the 4 verticals are sold independently from $1K-20K.

Source: workspacehub.app

Happy to answer architecture questions.

## Indie Hackers post

**Title**: How I packaged one Flutter codebase as 5 products (and why I dropped 3 features that were "must-have")

**Body**:
Three months ago I had a single Flutter project: "google_apis_flutter — a Google Workspace integration." Today it's shipping as 5 separately-sellable products on the same codebase.

The pivot story:
1. **Realized "Google Workspace app" doesn't sell.** Too generic. Every solo Flutter dev can build it.
2. **Picked specific verticals that each have a clear buyer.** BizCalendar for remote teams. DriveVault for power users. SheetsOps for ops teams. MeetCompanion for meeting-heavy roles.
3. **Same codebase, Flutter flavors.** Per-vertical entry points + feature flags + branding. Build any of them with one command.
4. **Dropped 3 features that looked good in marketing but were dead weight.**
   - Google Docs: API isn't suited to mobile editing
   - Google Keep: no official API
   - Google Analytics: mobile is the wrong form factor

The biggest unlock was **avoiding Google's CASA Security Assessment** ($15K-75K + 6 months) by designing every feature around SENSITIVE OAuth scopes only. Means a buyer can ship to Workspace Marketplace without paying Google a dime in security fees.

Pricing matrix:
- Starter kit license: $99-299
- Per-vertical license: $1K-20K
- Integration-as-a-service: $3K-15K per project

Source + vertical landings at workspacehub.app

## YouTube short script (60s)

[Hook] "If you've ever built Google Workspace integration in Flutter, you know it's 80% boring infrastructure. Here's a starter kit that does it once, for you."

[Demo] 30 seconds of fast cuts: sign-in, multi-account switch, calendar event with Meet link, file upload to Drive, send email with attachment, view sheets dashboard.

[Differentiator] "No restricted OAuth scopes. Means you ship via brand verification alone — no $15K Security Assessment."

[CTA] "workspacehub.app — link in description. License is $99-299."
