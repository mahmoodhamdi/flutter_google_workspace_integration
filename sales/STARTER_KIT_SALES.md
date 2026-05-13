# Starter Kit Sales — Workspace Hub

This document covers how to sell the **starter kit** specifically (Model 1).

## Target buyer

A Flutter developer or small agency who:
- Already builds Flutter apps for clients or for themselves
- Has a Workspace integration project on the near horizon
- Values time saved over getting the lowest possible price

## Hook (3 sentences)

> "If you're building a Flutter app that touches Google Calendar, Drive, or Sheets, you're about to spend 200 hours on multi-account OAuth, token refresh, offline cache, and CI before you even write a feature. Workspace Hub does that 200 hours for you, and uses only SENSITIVE OAuth scopes so you can publish to Workspace Marketplace without the $15,000+ CASA Security Assessment. License for $99-299, use forever."

## Differentiators (vs writing it yourself)

1. **Avoids CASA assessment** — designed-around restricted scopes by replacing every restricted scope with the closest sensitive equivalent. This single decision saves the buyer 3-6 months and $15K-$75K.
2. **Multi-account auth is hard** — every dev underestimates it. We've already shipped: secure token store per account, refresh interceptor, scope expansion flow, biometric lock.
3. **Real production polish** — error mapping for every status code, exponential-backoff retry on transient errors, offline-first cache with sync queue, AR/EN localization with RTL, 170+ tests.
4. **5 ready-to-ship verticals** — base + 4 Flutter flavors. Buyer can pick one and ship in days, or sell all four.
5. **CI included** — analyze, test, build matrix per flavor, release on tag — already set up.

## Anti-objections (and answers)

### "I can just write this myself."
> True. I did. Took 3 months. Workspace Hub gets you there in a weekend.

### "$299 is a lot."
> An average Flutter contractor charges $80/hour. Workspace Hub saves the average buyer ~200 hours. The math works.

### "Why not free / open source?"
> A solid maintained codebase needs paid time. We chose a low price ($99-299) and a permissive license rather than a freemium + premium tier. You pay once, you own it.

### "What if it's full of bugs?"
> 170+ tests run on every push. CI must pass before merge. Bug reports get fixed; security issues prioritized. Issue tracker is public.

### "What if Google changes the API?"
> All API calls are in single-purpose datasource files. When Google deprecates an endpoint, you update one file. Plus: Lifetime tier includes updates indefinitely.

### "I want to use BLoC, not Riverpod."
> Most of the code (data layer, domain, error mapping) is state-management-neutral. Migrating the UI from Riverpod to BLoC is ~40-60 hours — still cheaper than building from zero.

## Sales channels

### CodeCanyon
- Plays well to the "I'll buy a template" audience
- 30%-50% revenue share, but reach is real
- List under "Mobile App Templates → Flutter"
- Use Pro pricing ($199) since CodeCanyon buyers expect to pay

### Gumroad
- Higher margin (5% + payment fees)
- Direct relationship with buyers
- Push from your own audience (Twitter, blog)
- All 3 tiers available

### Direct from workspacehub.app
- Highest margin (just payment processor fees)
- Lifetime tier here only — premium signal
- Stripe checkout, instant access to private GitHub repo

### Flutter community channels
- r/FlutterDev showcase post (1 launch + 1 update per year max — don't spam)
- Flutter Community Slack / Discord
- Twitter/X — thread + replies in #FlutterDev
- HackerNews (Show HN once)
- Indie Hackers — "lessons learned" style post

### Paid acquisition (optional)
- Google Ads on "Flutter Google Calendar integration" type queries — small budget ($200/mo) to test
- LinkedIn Sales Navigator outreach to "Flutter Developer" titles in target geos

## Pricing experiments

**A/B candidates**:
- Drop Basic to $79 (more conversions, lower ARPU?)
- Add a "Team" tier at $599 (5 seats, agencies)
- Bundle starter kit + 1 vertical at $1,499 (cross-sell)

**Do not test**: removing Lifetime. It's the anchor that makes Pro look reasonable.

## Conversion funnel

1. **Awareness**: landing page or post → click to workspacehub.app
2. **Interest**: scrolls past "What's included" + sees "What you save" (hours table)
3. **Consideration**: clicks pricing, hovers tier cards
4. **Friction reducer**: small FAQ inline (license terms, refund policy)
5. **Purchase**: Stripe → "instant access" page → repo invite email
6. **Onboarding** (within 24h): welcome email with "Getting Started" walkthrough video link + Discord/Slack invite
7. **Upsell** (within 30 days): email with "Want to ship a vertical from your starter kit? Here's how" → cross-sell to Model 2

## Annual targets (year 1)

| Tier      | Units sold | Revenue   |
|-----------|------------|-----------|
| Basic     | 200        | $19,800   |
| Pro       | 80         | $15,920   |
| Lifetime  | 30         | $8,970    |
| **Total** | **310**    | **$44,690** |

**Assumes**: 1 CodeCanyon launch + 1 r/FlutterDev post + Twitter/X presence + occasional content marketing. No paid spend.

With paid acquisition ($500/mo on LinkedIn + Google Ads): 2x multiplier reasonable in year 2.
