# Marketing sites

Five static landing pages — one per vertical + a master starter-kit site.

## Sites

| Path | Site | URL (suggested) |
|------|------|-----------------|
| `base/`           | Workspace Hub (starter kit)   | workspacehub.app |
| `bizcalendar/`    | BizCalendar                   | bizcalendar.app  |
| `drivevault/`     | DriveVault                    | drivevault.app   |
| `sheetsops/`      | SheetsOps                     | sheetsops.app    |
| `meetcompanion/`  | MeetCompanion                 | meetcompanion.app |

## Deploy

Each site is plain static HTML/CSS — no build step. Deploy any of them by:

```bash
# Vercel (recommended)
cd marketing-sites/bizcalendar
vercel --prod

# Netlify
cd marketing-sites/bizcalendar
netlify deploy --prod --dir .

# GitHub Pages — push to gh-pages branch
# Cloudflare Pages — point at marketing-sites/bizcalendar
```

## Customization

White-label buyers:
1. Replace email addresses (`sales@bizcalendar.app` -> your inbox)
2. Swap the favicon and OG image
3. Update pricing to your tier
4. Add a payment provider integration (Stripe, Paddle, Gumroad)
5. Optional: add a contact form (Formspree or Netlify Forms work without a backend)

## Headers

`vercel.json` at the root sets baseline security headers (X-Frame-Options,
Referrer-Policy, Permissions-Policy denying camera/mic/geolocation for sales
sites). Apply the same headers when deploying to other platforms.
