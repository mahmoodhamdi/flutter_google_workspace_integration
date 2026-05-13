# OAuth Scopes Explained — Why Our Choice Saves Buyers $15,000+

This document is **the most important sales asset we have**. It explains a market mechanic most Flutter developers do not know about — and the savings it implies.

---

## TL;DR

Google classifies OAuth scopes into three tiers:

1. **Non-sensitive** (rare for Workspace) — automatic approval
2. **Sensitive** — requires Brand Verification (1-2 months, free)
3. **Restricted** — requires **CASA Security Assessment** (3-6 months, **$15,000 - $75,000 in fees** paid to a third-party auditor like Bishop Fox or Leviathan)

**Workspace Hub uses ZERO restricted scopes.** Every integration is designed around the closest sensitive-or-lower scope. This means a buyer can publish their app on Google Workspace Marketplace via the standard brand verification flow alone — **without paying $15K+ to a security auditor**.

---

## What scopes we use

| Feature       | Scope                                                            | Tier      | Brand verif? | CASA? |
|---------------|------------------------------------------------------------------|-----------|--------------|-------|
| Calendar      | `https://www.googleapis.com/auth/calendar`                       | Sensitive | Required     | **No** |
| Drive         | `https://www.googleapis.com/auth/drive.file`                     | Sensitive | Required     | **No** |
| Drive (list)  | `https://www.googleapis.com/auth/drive.metadata.readonly`        | Sensitive | Required     | **No** |
| Sheets        | `https://www.googleapis.com/auth/spreadsheets`                   | Sensitive | Required     | **No** |
| Gmail (send)  | `https://www.googleapis.com/auth/gmail.send`                     | Sensitive | Required     | **No** |
| Contacts      | `https://www.googleapis.com/auth/contacts`                       | Sensitive | Required     | **No** |
| Userinfo      | `userinfo.email` + `userinfo.profile`                            | Non-sens. | Required     | **No** |

## What we explicitly avoid

| Scope                                              | Tier        | Why we avoid |
|----------------------------------------------------|-------------|--------------|
| `https://mail.google.com/`                         | Restricted  | Full Gmail mailbox. Reading inbox needs this. CASA required. |
| `https://www.googleapis.com/auth/gmail.modify`     | Restricted  | Modify/move messages. CASA. |
| `https://www.googleapis.com/auth/gmail.readonly`   | Restricted  | Read mail. CASA. |
| `https://www.googleapis.com/auth/drive`            | Restricted  | Full Drive (all files). CASA. |
| `https://www.googleapis.com/auth/drive.readonly`   | Restricted  | Read all of Drive. CASA. |

## Trade-offs we accept

| Feature       | Available with our scope | Not available without restricted scope |
|---------------|--------------------------|------------------------------------------|
| Gmail         | Send email               | Read inbox, organize labels, search mail |
| Drive         | Files we create/open     | Scan user's entire Drive |
| Sheets        | Full read/write          | (none — sheets has no restricted variant) |
| Calendar      | Full read/write          | (none — calendar has no restricted variant) |
| Contacts      | Full CRUD                | (none) |

These trade-offs are intentional. **For 80% of mobile productivity use cases, the SENSITIVE-only design is sufficient.** When a buyer's use case requires restricted scopes (e.g. an email client app, a full Drive search app), we tell them honestly and they choose to either:
1. Pivot to a sensitive-scope-friendly UX (recommended), OR
2. Pay for CASA themselves (we can introduce them to auditors)

## Brand Verification flow (what buyers go through)

After purchasing Workspace Hub, the buyer needs to publish under their own brand:

1. Create a Google Cloud Project
2. Configure OAuth consent screen (External, Sensitive scopes selected)
3. Submit for verification with:
   - App name + logo (trademark verified)
   - Privacy policy URL (we provide a template in `sales/PRIVACY_TEMPLATE.md`)
   - Terms of service URL (template in `sales/TERMS_TEMPLATE.md`)
   - YouTube demo video (90s) showing each scope's usage (template in `marketing/storyboards/`)
   - Application home page (the buyer's marketing site)
4. Wait 1-2 months for Google's review
5. **Done** — no CASA, no $15K+ fee

## CASA flow (what they'd go through WITHOUT our scope discipline)

For comparison, if they shipped with restricted scopes:

1-5. Everything above, PLUS:
6. Hire a CASA-listed third-party assessor: Bishop Fox, Leviathan, Cobalt Labs, etc.
7. Pay **$15,000 - $75,000** for the assessment depending on app complexity
8. Wait 2-6 weeks for assessor engagement to start
9. Assessor runs penetration tests, code review, architecture review (4-12 weeks)
10. Pass assessment → certificate issued
11. Submit certificate to Google (additional 2-4 week review)
12. Renew assessment annually ($5,000-$15,000/year)

**Total cost difference**: $15K-75K upfront + $5K-15K/year recurring, AND 3-6 months extra wait.

## Use this as a sales talking point

When a Flutter dev asks "why $99 / $199 / $299, isn't that a lot for a starter kit?":

> "The scope strategy alone saves the typical buyer $15,000-$75,000 in CASA Security Assessment fees. The starter kit pays for itself ~50x over on that one decision."

When an enterprise buyer asks "what makes you different from a freelancer":

> "A freelancer building from scratch will use whatever scope is convenient — typically defaulting to `gmail.modify` because the tutorials use it. We've designed every integration around SENSITIVE scopes only. That's the difference between a 2-month Marketplace approval and a 6-month one."

## References (for verification)

- Google's OAuth verification tiers: https://support.google.com/cloud/answer/9110914
- CASA assessment overview: https://appdefensealliance.dev/casa
- CASA assessor list: https://appdefensealliance.dev/casa/casa-assessors (Bishop Fox, Leviathan, etc — current pricing is request-quote)
- Workspace Marketplace listing requirements: https://workspace.google.com/marketplace
