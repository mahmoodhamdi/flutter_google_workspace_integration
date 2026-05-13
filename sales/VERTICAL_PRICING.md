# Vertical Product Pricing — Detailed Notes

Per-vertical buyer profile, value propositions, and pricing rationale.

---

## BizCalendar

### Buyer profile
- **Title**: CTO, Engineering Manager, Head of Operations
- **Company size**: 10-200 people, remote-first or hybrid
- **Pain**: Calendly is great for external scheduling but useless for internal team scheduling. Google Calendar is the storage layer but lacks team-level intelligence.
- **Budget**: $1,500-15,000 for a self-hosted internal tool that saves 5+ hrs/week across the team

### Value calculation (talking point)
> "Your team of 30 people each loses 1 hour per week to scheduling friction. At $80/hr loaded cost, that's $124,800/year. BizCalendar's $4,500 white-label license pays for itself in 2 weeks."

### Pricing rationale
- **$1,500 self-hosted**: cheap enough that a Director can approve without finance signoff
- **$4,500 white-label**: priced at 2-3x self-hosted (typical white-label premium) to signal "you can rebrand this as your own product"
- **$15,000 enterprise**: starts the SLA + custom-feature conversation; quote up from here as needed

### Most common asks (and how to price them)
| Custom request | Add to base | Why |
|----------------|-------------|-----|
| SSO integration (Okta/Auth0) | +$3,000 | 1 week eng |
| Slack notifications integration | +$1,500 | 2-3 days eng |
| Custom report generation (PDF export) | +$2,500 | 1 week eng |
| White-label web companion app | +$8,000 | 3-4 weeks eng |

---

## DriveVault

### Buyer profile
- **Title**: Solo consultant, photographer, journalist, lawyer — anyone whose Drive *is* their business archive
- **Variant 2**: small agency (5-30 people) wanting team-wide backup as a policy
- **Pain**: Drive is great storage but it's not a backup. Lose a file? Lose folder structure? Files modified by a teammate? No fast recovery.
- **Budget**: $1,500-15,000 (most solo buyers go self-hosted; agencies go white-label or enterprise)

### Value calculation (talking point)
> "If your business archive is in Drive, you've got one copy. DriveVault gives you a second, encrypted local copy with OCR-searchable scans. The cost of losing 1 critical client file = months of recovery cost."

### Pricing rationale
- Identical to BizCalendar — both are "backbone productivity" sales.
- White-label highly relevant: privacy-focused brands (e.g. legal SaaS, photo backup services) can resell with credibility.

### Most common asks
| Custom request | Add to base |
|----------------|-------------|
| Encrypted cloud backup destination (S3/Wasabi) | +$3,500 |
| Cron-style backup scheduler | +$1,500 |
| Multi-Drive (combine personal + work) backup | +$2,500 |
| Compliance report (HIPAA/GDPR) | +$5,000 |

---

## SheetsOps

### Buyer profile
- **Title**: Ops Manager, Finance Analyst, Product Manager, Founder
- **Company size**: Any size with a power-user spreadsheet culture
- **Pain**: Built a beautiful sheet but their team only checks it on desktop. Want dashboards on their phone but can't justify Tableau/Looker for one chart.
- **Budget**: $2,000-20,000 (slightly higher than other verticals because customers value "real-time" data more)

### Value calculation
> "Stop emailing screenshots of your spreadsheet to executives. SheetsOps converts your sheet to a real-time mobile dashboard. They'll check it daily; you'll never get 'can you send the latest numbers?' again."

### Pricing rationale
- Priced 33% higher than BizCalendar/DriveVault — buyers comparing to Tableau/Looker rather than "free Calendar app"
- Enterprise tier especially relevant for finance/ops teams who need SLA and access control

### Most common asks
| Custom request | Add to base |
|----------------|-------------|
| Custom chart type (gauge, waterfall) | +$1,500/chart |
| Slack alert when threshold crossed | +$1,500 |
| Multi-sheet aggregation dashboard | +$3,000 |
| Embedded dashboards in web | +$4,000 |
| Custom auth (LDAP/SAML) | +$5,000 |

---

## MeetCompanion

### Buyer profile
- **Title**: anyone with 15+ hrs/week of meetings — heaviest skew is sales leadership, customer success, exec assistants
- **Pain**: Meet itself is great audio/video, but the surrounding ritual (prep, notes, action items, follow-up) is manual and forgotten
- **Budget**: $1,000-10,000 (lowest of the 4 verticals because individual-buyer skew is higher)

### Value calculation
> "You spend 12 hours a week in meetings. MeetCompanion makes each one 20% more productive. That's 2.4 hours/week reclaimed. At $80/hr, that's $9,984/year — for a tool that costs $1,000 to self-host."

### Pricing rationale
- Lowest tier of the 4 — buyers are individuals + small teams, fewer enterprise asks
- Enterprise tier exists for sales orgs / customer success teams that buy seat-style productivity tools

### Most common asks
| Custom request | Add to base |
|----------------|-------------|
| AI-generated meeting summary (LLM integration) | +$3,000 |
| CRM sync (Salesforce/HubSpot for action items) | +$2,500 |
| Custom prep-card templates per meeting type | +$1,500 |
| Voice memo transcription | +$3,000 |

---

## Pricing matrix (master quick reference)

|              | Self-hosted | White-label | Enterprise |
|--------------|-------------|-------------|------------|
| BizCalendar  | $1,500      | $4,500      | $15,000+   |
| DriveVault   | $1,500      | $4,500      | $15,000+   |
| SheetsOps    | $2,000      | $6,000      | $20,000+   |
| MeetCompanion| $1,000      | $3,000      | $10,000+   |
| **Bundle**   | **$5,000**  | **$14,000** | **$40,000+** |

## When to use which tier in a quote

| Buyer says... | Quote tier |
|---------------|------------|
| "I want to ship this as my own product" | White-label |
| "I want to deploy this internally only" | Self-hosted |
| "We need it customized for our compliance/process" | Enterprise |
| "We're a small startup, budget is tight" | Self-hosted with 25% startup discount |
| "We're an agency reselling this to clients" | White-label, multi-license discussion |
