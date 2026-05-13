# OAuth Scope Tracker — flutter_google_workspace_integration

**Hard rule**: zero RESTRICTED scopes. All scopes must be SENSITIVE or below.
Source: https://support.google.com/cloud/answer/9110914

## Scope Inventory by Feature

| Feature           | Scope                                                                  | Classification | CASA required? |
|-------------------|------------------------------------------------------------------------|----------------|----------------|
| Calendar          | `https://www.googleapis.com/auth/calendar`                             | sensitive      | No |
| Calendar (Meet)   | `https://www.googleapis.com/auth/calendar.events`                      | sensitive      | No |
| Drive             | `https://www.googleapis.com/auth/drive.file`                           | sensitive      | No |
| Drive (list-only) | `https://www.googleapis.com/auth/drive.metadata.readonly`              | sensitive      | No |
| Sheets            | `https://www.googleapis.com/auth/spreadsheets`                         | sensitive      | No |
| Gmail (send-only) | `https://www.googleapis.com/auth/gmail.send`                           | sensitive      | No |
| Contacts          | `https://www.googleapis.com/auth/contacts`                             | sensitive      | No |
| Profile (basic)   | `https://www.googleapis.com/auth/userinfo.email`                       | non-sensitive  | No |
| Profile (basic)   | `https://www.googleapis.com/auth/userinfo.profile`                     | non-sensitive  | No |
| Maps              | (API key, no OAuth)                                                    | n/a            | No |
| Meet              | (uses Calendar API conferenceData — no separate scope)                 | n/a            | No |

## Verification Path

For Google Workspace Marketplace publication:

1. **Brand verification** (1–2 months, free)
   - Trademark verification of app name + logo.
   - Privacy policy + terms of service URLs.
   - YouTube demo video (90 seconds).
   - In-app screens demonstrating each scope's usage.
2. **OAuth verification** (1–2 months, free) — covers all sensitive scopes.
3. **Workspace Marketplace listing** (2–6 weeks, free) — listing review.

**Total time**: 3–10 months, **$0** in Google fees.

## What we explicitly avoid

| Scope                                              | Why we avoid |
|----------------------------------------------------|--------------|
| `https://mail.google.com/`                         | Restricted. Full Gmail. CASA required. |
| `https://www.googleapis.com/auth/gmail.modify`     | Restricted. Read + modify mail. CASA. |
| `https://www.googleapis.com/auth/gmail.readonly`   | Restricted. Read mail. CASA. |
| `https://www.googleapis.com/auth/drive`            | Restricted. Full Drive. CASA. |
| `https://www.googleapis.com/auth/drive.readonly`   | Restricted. Read all of Drive. CASA. |
| `https://www.googleapis.com/auth/photoslibrary`    | Restricted. Out of scope anyway. |
| `https://www.googleapis.com/auth/youtube`          | Restricted. Out of scope. |
| `https://www.googleapis.com/auth/admin.directory.*`| Restricted (admin). Out of scope. |

## Per-Vertical Scope Manifest

### BizCalendar
- calendar
- userinfo.email
- userinfo.profile

### DriveVault
- drive.file
- drive.metadata.readonly
- userinfo.email
- userinfo.profile

### SheetsOps
- spreadsheets (read/write for editing) OR spreadsheets.readonly (view-only edition)
- userinfo.email
- userinfo.profile

### MeetCompanion
- calendar.events
- drive.file (for meeting notes)
- userinfo.email
- userinfo.profile

### Starter Kit (Base, all features)
All sensitive scopes above. Buyer enables the subset they need per vertical.
