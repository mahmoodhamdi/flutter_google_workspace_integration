# Handover Checklist

Use this when delivering a starter kit license OR a services engagement.

## On license purchase (Model 1 — Starter Kit)

- [ ] Repo invite sent (private GitHub repo via the buyer's GitHub username)
- [ ] Welcome email sent with:
  - [ ] Link to README in the repo
  - [ ] Link to `sales/HANDOVER_CHECKLIST.md` (this file)
  - [ ] Link to a 5-min "first run" video (recorded once, shared with every buyer)
  - [ ] Discord/Slack support channel invite
  - [ ] Support email (`support@workspacehub.app`)
- [ ] Invoice PDF emailed (Stripe auto-generates; ensure billing details are correct for tax)

## On vertical product purchase (Model 2)

Everything above, PLUS:

- [ ] Vertical-specific brand assets pack (logos, splash, color tokens) emailed
- [ ] White-label tier only: rename guide ("how to change app name, bundle id, OAuth client") sent
- [ ] Workspace Marketplace publishing guide (`GOOGLE_WORKSPACE_MARKETPLACE_PUBLISHING.md`) emailed
- [ ] Optional: 30-min kickoff call scheduled (Calendly link in email)
- [ ] If Enterprise tier: dedicated Slack channel + named contact assigned

## On services engagement (Model 3)

Everything above, PLUS:

- [ ] SOW signed by both parties
- [ ] NDA in place (mutual or one-way as required)
- [ ] 50% deposit invoice sent & paid before code work begins
- [ ] Shared GitHub repo access granted (their repo or ours, agreed in SOW)
- [ ] Communication channel set up (Slack/Teams; not email)
- [ ] Daily standup time agreed (async ok)
- [ ] PR review owner identified on their side
- [ ] Test coverage minimum agreed (default 70% on new code)
- [ ] Final delivery checklist:
  - [ ] All in-scope features implemented
  - [ ] All tests passing in CI
  - [ ] Documentation handed over (architecture, scope decisions, troubleshooting)
  - [ ] 1-hour walkthrough call done
  - [ ] Final invoice (50% balance) paid
  - [ ] 90-day bug-fix warranty started

## Day 0 first-run video script (5 min)

Recorded once, shared with every buyer. The script:

1. [0:00-0:30] Welcome + repo access confirmation
2. [0:30-1:30] Repo tour — README, pubspec, key directories
3. [1:30-2:30] First build:
   - `flutter pub get`
   - `dart run build_runner build --delete-conflicting-outputs`
   - `flutter run --dart-define=FLAVOR=base`
4. [2:30-3:30] Auth setup — drop in `google-services.json`, configure OAuth client
5. [3:30-4:30] Pick a vertical (or base) — flavor flag, entry point, build script
6. [4:30-5:00] Where to ask questions (Discord) + support email + sales upsell tease

## What the buyer expects in their inbox (within 24h of purchase)

1. Confirmation email with download/access info (instant for digital, ≤ 24h for white-label)
2. Welcome email (separate from receipt) with handover checklist
3. Invitation to private support channel
4. Receipt / invoice for accounting

## Red flags during handover

- **Buyer hasn't responded in 7+ days**: send "checking in" email; offer a 15-min call
- **Repo invitation not accepted in 3 days**: their GitHub email may be wrong; ask
- **Multiple "how do I X?" questions in week 1**: prompt them to watch the first-run video; ALSO update the video/docs if multiple buyers ask the same Q
- **Refund request in week 2**: usually means scope mismatch or didn't read landing page. Listen, fix the documentation/landing page wording for future buyers, refund without argument

## Anti-leakage policy

- **License terms emphasized in welcome email**: source is for commercial use in your products, NOT for resale as a competing starter kit
- **One repo per buyer (or per team for Pro+)**: makes it trivial to identify who leaks
- **License key embedded in code** (Pro+ only): a generated constant in `lib/core/license_meta.dart` tied to the buyer's email/name. Easy to spot in any leaked copy.

## Post-handover (within 30 days)

- [ ] Send "How's it going?" email at day 14
- [ ] Send vertical upsell email at day 30 (if buyer is on starter kit, mention BizCalendar/etc)
- [ ] Optionally add buyer to "case study" pool — request permission to mention in marketing
- [ ] Track in CRM: which vertical they ended up shipping, time-to-ship, blockers (useful for product roadmap)
