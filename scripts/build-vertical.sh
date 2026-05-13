#!/usr/bin/env bash
# Build a single vertical of the Workspace app.
#
# Usage:
#   scripts/build-vertical.sh <flavor> [platform]
#
# flavor:   base | bizcalendar | drivevault | sheetsops | meetcompanion
# platform: apk | aab | web | ios (default: apk)
#
# Output: build artifacts under build/app/outputs/ for Android,
#         build/web for Web, build/ios for iOS.

set -euo pipefail

FLAVOR="${1:-base}"
PLATFORM="${2:-apk}"

if [[ ! "$FLAVOR" =~ ^(base|bizcalendar|drivevault|sheetsops|meetcompanion)$ ]]; then
  echo "Unknown flavor: $FLAVOR"
  echo "Valid: base, bizcalendar, drivevault, sheetsops, meetcompanion"
  exit 2
fi

ENTRY="lib/main.dart"
case "$FLAVOR" in
  bizcalendar)    ENTRY="lib/main_bizcalendar.dart" ;;
  drivevault)     ENTRY="lib/main_drivevault.dart" ;;
  sheetsops)      ENTRY="lib/main_sheetsops.dart" ;;
  meetcompanion)  ENTRY="lib/main_meetcompanion.dart" ;;
esac

echo "==> Building $FLAVOR ($PLATFORM) using $ENTRY"

flutter pub get
dart run build_runner build --delete-conflicting-outputs || true

CMD=()
case "$PLATFORM" in
  apk)
    CMD=(flutter build apk --release --split-per-abi
         --target "$ENTRY" --dart-define="FLAVOR=$FLAVOR")
    ;;
  aab)
    CMD=(flutter build appbundle --release
         --target "$ENTRY" --dart-define="FLAVOR=$FLAVOR")
    ;;
  web)
    CMD=(flutter build web --release
         --target "$ENTRY" --dart-define="FLAVOR=$FLAVOR")
    ;;
  ios)
    CMD=(flutter build ios --release --no-codesign
         --target "$ENTRY" --dart-define="FLAVOR=$FLAVOR")
    ;;
  *)
    echo "Unknown platform: $PLATFORM"
    exit 2
    ;;
esac

"${CMD[@]}"
echo "==> Build finished for $FLAVOR ($PLATFORM)"
