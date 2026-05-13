#!/usr/bin/env bash
# Build all 5 verticals (Android APK release) sequentially.
#
# Usage: scripts/build-all-verticals.sh
# Output: APKs copied to verticals-builds/

set -euo pipefail

OUTDIR="verticals-builds"
mkdir -p "$OUTDIR"

for FLAVOR in base bizcalendar drivevault sheetsops meetcompanion; do
  echo "==================== $FLAVOR ===================="
  scripts/build-vertical.sh "$FLAVOR" apk

  # Copy artifacts with flavor prefix
  for APK in build/app/outputs/flutter-apk/*.apk; do
    [ -f "$APK" ] || continue
    DEST="$OUTDIR/${FLAVOR}-$(basename "$APK")"
    cp "$APK" "$DEST"
    echo "  -> $DEST"
  done
done

echo "==> All 5 verticals built. APKs in $OUTDIR/"
ls -lh "$OUTDIR/"
