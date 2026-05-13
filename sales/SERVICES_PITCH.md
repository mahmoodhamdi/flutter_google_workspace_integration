# Services Pitch — Integration-as-a-Service

Sell integration services to companies that **already have a Flutter app** and just need Google Workspace dropped into it.

## Target buyer

- Has a working Flutter app in production or beta
- Wants to add Google Workspace (specifically: 1-7 of Calendar, Drive, Sheets, Gmail send, Contacts, Maps, Meet)
- Either: doesn't have time to build it, or doesn't have a senior Flutter dev on staff
- Budget: $3K-$15K for a one-time engagement

## Why us, not a freelancer

- **Pre-built foundation**: we drop the proven multi-account OAuth + token refresh + offline cache layer in. No rewriting from scratch.
- **OAuth scope discipline**: we know exactly which scopes avoid CASA. Your senior Flutter dev probably doesn't (and will burn 2 weeks finding out).
- **Workspace Marketplace publication**: we've shipped Workspace Marketplace listings before. Brand verification process documented.
- **Faster delivery**: 1-8 weeks. A freelancer building from zero needs 6-12 weeks for the same scope.
- **One-throat-to-choke**: not a marketplace gig; you sign with one entity, get one accountable team.

## Engagement workflow

### Week 0: Scoping call (free, 30 min)
- Understand the buyer's current Flutter app (architecture, state mgmt, package versions)
- Confirm which APIs they need + which scopes
- Identify auth model (are they using Firebase already? Google Sign-In?)
- Quote with itemized line items

### Week 1: Onboarding
- Sign SOW + 50% deposit
- Set up shared GitHub access, Slack/Teams channel
- Review their codebase, identify integration points

### Week 2-N: Build
- Daily standups (Slack-based, async)
- PR-based delivery against a shared `feat/workspace-integration` branch
- Their team reviews each PR before merge
- Test coverage stays at or above 70% of new code

### Final week: Handover
- Documentation handoff: integration map, scope decisions, scope-expansion flow, troubleshooting guide
- 1-hour walkthrough call with their senior dev
- 90-day bug fix warranty starts

### Optional post-engagement
- Maintenance retainer: $500/mo for monitoring + bug fixes + minor updates
- Brand verification support: $2,000 flat (we handle Google's review correspondence)
- Workspace Marketplace publication: $1,500 flat

## Pricing breakdown (Standard $7,500 example)

| Line item | Hours | Price |
|-----------|-------|-------|
| Auth foundation (multi-account, refresh, secure storage) | 16h | $1,280 |
| Calendar integration (CRUD + recurrence + Meet) | 24h | $1,920 |
| Drive integration (drive.file scope, upload/download/share) | 20h | $1,600 |
| Contacts integration (People API CRUD) | 12h | $960 |
| Tests (unit + widget + integration) | 16h | $1,280 |
| Documentation + handover | 6h | $480 |
| Project management | proportional | $480 |
| **Total** | **94h** | **$8,000** (rounded to $7,500) |

Effective rate: ~$80/hr, but priced as a fixed-scope deliverable so the buyer doesn't worry about scope creep.

## Anti-objections

### "We can hire a freelancer for $4,000."
> True — for the build time. But (a) we have a 200-hr foundation already built into the deliverable, and (b) you save another 200+ hrs of CASA assessment by inheriting our scope strategy. Compared apples-to-apples, our $7,500 vs their $4,000 + 6-month Google review = we win.

### "We want to use our own OAuth code."
> Fine — we can adapt to your existing google_sign_in / firebase_auth setup. The token-refresh and scope-expansion logic is the value-add, not the SDK choice. Quote unchanged.

### "Can you do it cheaper if we provide design specs?"
> Yes — designs ready means -20% (design+dev cycles compressed). Don't drop below $2,500 for a single-API engagement; below that, our value-add disappears.

### "What if we need [obscure scope]?"
> If it's RESTRICTED (gmail.modify, drive.readonly, etc), we'll flag it during scoping. Adding it requires CASA assessment — we'll either price that in ($15K-75K + 3-6 months) or recommend an alternative SENSITIVE scope that achieves 90% of the use case.

### "Do you sign NDAs?"
> Yes. Standard mutual NDA via DocuSign before we look at their code.

## Discovery questions (use these on scoping calls)

1. What's your current Flutter app stack? (Flutter version, state mgmt, auth, networking)
2. Which Workspace APIs do you need? (List the 7 we support; ask which they want)
3. Do users sign in with Google already, or just email/password?
4. Do you need multi-account? (Power users almost always do)
5. Do you need offline support?
6. Do you plan to publish to Google Workspace Marketplace?
7. What's your timeline target? (Anything < 4 weeks needs scope cut or rush surcharge)
8. Who on your team will review PRs? (We need a primary contact)

## Lead sources

### LinkedIn
- Sales Navigator search: "Flutter Developer" + "Google Workspace" mentions in profile
- Posts: showcase work, soft CTA "DM if you're building something similar"
- Cold outreach is OK if the message is specific: "I noticed your app uses Google Sign-In; if you ever need to add Calendar, here's what I do."

### Upwork
- Higher friction, lower margin, but real lead flow
- Pin "Flutter Google Workspace" as a saved search
- Apply only to >$3K postings; below that, profit margin too thin

### Toptal
- Pre-vetted talent platform; matched to enterprise clients
- Higher per-hour rate ($100+) but Toptal takes a cut
- Worth applying once we have 3+ successful engagements as references

### Agency partnerships
- Reach out to Flutter-focused agencies who get RFPs for Workspace integration
- Offer 15% white-label commission for referrals → "you bring the client, we do the work, you keep your client relationship"
- Most effective inbound: relationships with 2-3 mid-sized agencies = 3-5 leads/quarter

### Workspace Hub (Model 1) cross-sell
- Starter-kit buyers who can't execute themselves convert to services buyers ~10% of the time
- Email cadence: at 30 days post-purchase, send "Need help wiring this in? Reply here."

## Annual target (year 1)

| Engagement type | Count | Avg revenue | Total |
|-----------------|-------|-------------|-------|
| Single-API engagements | 4 | $3,500 | $14,000 |
| Standard packages | 3 | $7,500 | $22,500 |
| Comprehensive packages | 2 | $14,000 | $28,000 |
| Maintenance retainers (avg 6 mo) | 4 | $3,000 | $12,000 |
| **Year 1 services revenue** | | | **$76,500** |

Combined with Starter Kit and Verticals goals, total year-1 revenue target: **$140K-180K**.
