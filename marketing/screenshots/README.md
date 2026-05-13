# Screenshots

Marketing screenshots are generated programmatically via the goldens
infrastructure in `test/golden/screenshot_generation_test.dart`.

## Regenerate all screenshots

```bash
flutter test --update-goldens test/golden/screenshot_generation_test.dart
# Then copy from test/golden/goldens/ to here, organized by vertical:
mkdir -p marketing/screenshots/base
cp test/goldens/marketing_*.png marketing/screenshots/base/
```

## Why programmatic, not screenshotted devices?

- **Reproducible**: every release rerun produces pixel-identical output.
- **Translates automatically**: change a string in an .arb file, regenerate, the screenshot reflects the new copy.
- **Cheaper than real devices**: no need for an emulator farm or test phones.
- **Theme variants free**: light/dark/RTL all from one source.

## Per-vertical screenshots

For BizCalendar / DriveVault / SheetsOps / MeetCompanion, override `AppConfig`
in test setup before pumping the widget so the brand colors apply, then save
into the corresponding `marketing/screenshots/<vertical>/` directory.
