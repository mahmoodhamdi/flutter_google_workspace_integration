# Branding Assets

Per-vertical branding overrides live here. Each vertical (bizcalendar, drivevault, sheetsops, meetcompanion) ships with its own logo, color palette, and onboarding illustrations placed in:

```
assets/branding/<vertical>/
├── logo.png        # 1024x1024 (square)
├── logo_wide.png   # 1024x256 (wordmark)
├── splash.png      # 2732x2732 (centered for adaptive)
├── adaptive_fg.png # 432x432 (Android adaptive foreground)
├── adaptive_bg.png # 432x432 (Android adaptive background)
└── colors.json     # `{primary, onPrimary, surface, ...}`
```

Buyers replace these to white-label.

The `flutter_launcher_icons` / `flutter_native_splash` tooling reads `flutter_launcher_icons-<vertical>.yaml` configs at the repo root.
