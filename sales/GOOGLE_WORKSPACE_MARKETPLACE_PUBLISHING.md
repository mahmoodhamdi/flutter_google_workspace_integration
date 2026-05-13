# Publishing Your App to Google Workspace Marketplace

A step-by-step guide for buyers who want to publish a derivative of Workspace
Hub (or a vertical) on the official Workspace Marketplace.

## Prerequisites

- Google Cloud project (separate from any test project)
- Verified domain (you control DNS and have an MX record OR a verified TXT record)
- Trademark on your app name (recommended for trouble-free verification)
- Privacy policy + Terms of service hosted on your domain
- 90-second YouTube demo video (unlisted is fine for review; public after approval)
- A real device or emulator running your app for screenshots

## Step 1: Google Cloud Project Setup

1. Go to https://console.cloud.google.com/
2. Create a **new** project (don't reuse your development project)
3. Note the project ID — you'll need it later
4. Enable these APIs (Library → search → Enable):
   - Google Calendar API
   - Google Drive API
   - Google Sheets API
   - Gmail API (only if you use gmail.send)
   - People API (for Contacts)
   - Maps SDK for Android + iOS + JavaScript (only if you use Maps)

## Step 2: OAuth Consent Screen

1. Go to APIs & Services → OAuth consent screen
2. Choose **External** (unless you're publishing for a single Workspace domain)
3. Fill in:
   - **App name**: your product's actual name (e.g. "BizCalendar")
   - **User support email**: support@your-domain.com
   - **App logo**: 120x120 PNG, ≤1 MB
   - **App domain**:
     - Homepage: https://your-domain.com
     - Privacy policy: https://your-domain.com/privacy
     - Terms of service: https://your-domain.com/terms
   - **Authorized domains**: add your-domain.com
   - **Developer contact**: your email
4. **Scopes** — select the SENSITIVE scopes you need:
   - `https://www.googleapis.com/auth/userinfo.email`
   - `https://www.googleapis.com/auth/userinfo.profile`
   - Plus the per-feature scopes (see `OAUTH_SCOPES_EXPLAINED.md`)
5. Add **test users** (your developer accounts) for the initial testing phase
6. Save

## Step 3: OAuth Client IDs

1. APIs & Services → Credentials → Create credentials → OAuth client ID
2. Application type:
   - **Android**: package name + SHA-1 of your signing cert
   - **iOS**: bundle ID
   - **Web**: authorized redirect URIs
3. Download `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)
4. Place files in your app per platform's standard location:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

**Important**: Do NOT commit these files. Add to `.gitignore` (Workspace Hub already does).

## Step 4: Brand Verification

For SENSITIVE scopes, you must complete brand verification before any non-test user can sign in.

1. From OAuth consent screen → "Publish App" button
2. App status will move from "Testing" to "In production"
3. Google then prompts for verification — typically 1-2 weeks for response
4. Provide:
   - Demo video (90 seconds, showing each scope being used)
   - In-app screenshots demonstrating scope usage
   - Justification for each sensitive scope
5. Possible outcomes:
   - **Approved**: scope is now usable for all users
   - **Reduce scope**: Google may suggest a less-permissive scope
   - **Reject**: typically due to a mismatch between requested scope and demonstrated use case; appeal with clearer evidence

## Step 5: Workspace Marketplace SDK

Only required if you want listing on the actual Marketplace (not just OAuth approval).

1. APIs & Services → Library → Enable "Google Workspace Marketplace SDK"
2. Go to Marketplace SDK → App Configuration:
   - **App integration**: pick what your app is (Add-on, Editor add-on, Mobile app, Standalone web app)
   - **OAuth scopes**: pre-populated from your consent screen
   - **Required permissions**: list per-API permissions your app reads/writes
3. Marketplace SDK → Store Listing:
   - Listing language(s) — we recommend English + Arabic for MENA reach
   - Logos: 32x32, 128x128, 220x140 banner, screenshots
   - Short description (max 200 chars)
   - Long description (max 16,000 chars)
   - Category — pick the closest match (Calendar, Productivity, etc.)
   - Privacy policy + Terms URLs (same as OAuth screen)
   - Support email + URL

## Step 6: Verification submission

1. Marketplace SDK → "Publish app"
2. Google reviews — typically 2-6 weeks
3. Possible follow-up emails asking for:
   - Clearer video of a specific feature
   - Proof of trademark for the app name
   - Privacy policy clarifications

## Step 7: Maintenance

After approval, you should:
- Re-submit verification when adding NEW sensitive scopes
- Submit re-verification at least annually (Google notifies via email)
- Respond to any abuse reports within 48 hours

## Common pitfalls

1. **Using a personal Gmail account as developer contact** — Google reviewers may bounce this. Use a domain email.
2. **Video shows non-OAuth screens only** — must show OAuth consent in action, then the scope being used.
3. **Generic logo** — must be unique to your app (not a free icon set image).
4. **Listing description duplicated** — looks like a clone of another listing → flagged for manual review.
5. **Privacy policy doesn't explicitly cover data accessed** — must list each Google API your app touches.
6. **Tests still listed in consent screen** — remove test users before going to production.

## What we (Workspace Hub) can help with

For enterprise / services customers, we offer a **Workspace Marketplace publication add-on** ($1,500 flat) where we:
- Prepare the OAuth consent screen submission
- Write the privacy policy + terms (templated)
- Coach on the YouTube demo video script
- Liaise with Google reviewers on your behalf
- Provide app verification audit (we run your config through a pre-submission checklist)

Quote separately from base licenses. Always.
