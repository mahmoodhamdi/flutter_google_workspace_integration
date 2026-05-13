# Support Plans

What's included at each price point, and what isn't.

## Starter Kit support (by tier)

### Basic ($99)
- **Channel**: Community Discord (best-effort, asynchronous)
- **Response time**: no SLA
- **Included**: bug reports against vanilla codebase, "how do I run it" type questions
- **NOT included**: code review of your custom features, debugging your modifications, custom feature requests, architecture consulting

### Pro ($199)
- **Channel**: Email + Discord
- **Response time**: 24-72 hours business days
- **Window**: 30 days from purchase
- **Included**: everything in Basic, plus debugging assistance on your modifications, OAuth setup walkthroughs, build/CI troubleshooting
- **NOT included**: writing your custom features for you, design work

### Lifetime ($299)
- **Channel**: Priority email + Discord + 1 hour video call
- **Response time**: 24 hours business days (Mon-Fri 9am-5pm Cairo time)
- **Window**: indefinite for the same major version
- **Included**: everything in Pro, plus version-update assistance when Flutter/Google APIs ship breaking changes, priority bug fix scheduling, 1-hour Q&A call on signup
- **NOT included**: building features from scratch for you, ongoing maintenance retainer (separate Model 3 service)

## Vertical product support (by tier)

### Self-hosted ($1K-2K)
- **Channel**: Email
- **Response time**: 48 hours business days
- **Window**: 6 months
- **Included**: bug fix releases, OAuth/Marketplace publication guidance, deployment troubleshooting
- **NOT included**: custom feature development, on-call support, multi-tenant deployment advice

### White-label ($3K-6K)
- **Channel**: Email + dedicated Slack channel
- **Response time**: 24 hours business days
- **Window**: 12 months
- **Included**: everything in Self-hosted, plus branding swap consultation, onboarding session (1 hour), 1 custom feature included up to 8 hours work
- **NOT included**: backend infrastructure, hosting, ongoing maintenance

### Enterprise ($10K-20K+)
- **Channel**: Dedicated account manager, Slack channel, video calls as needed
- **Response time**: 4 hours business days; 8 hours for non-critical weekend issues
- **Window**: 12 months, renewable annually
- **Included**: everything in White-label, plus SLA-backed bug fixes (P0 within 24h, P1 within 72h), quarterly check-in, 40 hours of custom development included, security review on request
- **NOT included**: 24/7 on-call (priced separately if needed), full-stack work outside the Flutter app

## Services support (Model 3)

Engagements include 90 days of post-delivery bug fixes for issues introduced during our work. After that, customer either:

1. **Self-supports** (we hand over comprehensive docs)
2. **Monthly maintenance retainer**: $500/mo per integration scope, billed quarterly

### What's included in $500/mo maintenance:
- Monitoring of Google API deprecation announcements; proactive fix PRs when impacted
- Up to 2 bug fix PRs per month at no additional charge
- Up to 1 hour of code review per month for the customer's internal team
- Priority response (24h)

### What's NOT included:
- New features (those are separate $1.5K-5K quoted projects)
- Workspace Marketplace re-verification (we charge $1,500 each)
- Performance optimization (quoted separately)

## Escalation matrix

| Issue severity | Definition | Pro | Lifetime | Vertical SH | Vertical WL | Enterprise |
|----------------|------------|-----|----------|-------------|-------------|------------|
| P0 (app broken in production) | App won't start, OAuth flow broken, data loss bug | 48h | 24h | 24h | 12h | 4h |
| P1 (feature broken) | One feature unusable; workaround possible | 72h | 48h | 48h | 24h | 24h |
| P2 (cosmetic / minor) | UI glitch, copy issue, edge case | 1 wk | 72h | 1 wk | 48h | 48h |
| Question | Usage / configuration / docs | 72h | 24h | 72h | 24h | 4h |

## Out-of-scope guidance

When a customer asks something not in their tier, the response template:

> "Hi! That question isn't covered by your [tier] support — it falls under [tier-needed]. I can either:
>  (a) Quickly answer in our community Discord (no SLA), or
>  (b) Quote $X for a one-off engagement to handle this properly.
>
> Which works for you?"

Never just say "out of scope" — always offer the upsell or downsell.

## When to escalate to refund

Customer is unhappy with support? Refund threshold rules:

| Tier | Refund window | Conditions |
|------|---------------|------------|
| Basic | 7 days | Full refund, no questions |
| Pro | 7 days | Full refund, repo access revoked |
| Lifetime | 14 days | Full refund, repo access revoked |
| Vertical SH | 14 days | Full refund if no production deployment yet |
| Vertical WL | 30 days | 80% refund (we keep 20% for onboarding cost) |
| Enterprise | Case-by-case in SOW | Typically pro-rated against delivered milestones |

**Never refund**: services engagements past deposit (those are commit-to-deliver agreements).
