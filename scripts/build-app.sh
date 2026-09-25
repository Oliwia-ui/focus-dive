#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIGURATION="${1:-release}"
APP="$ROOT/dist/Focus Dive.app"
CONTENTS="$APP/Contents"
MACOS="$CONTENTS/MacOS"

cd "$ROOT"
swift build -c "$CONFIGURATION"
BIN_DIR="$(swift build -c "$CONFIGURATION" --show-bin-path)"

rm -rf "$APP"
mkdir -p "$MACOS" "$CONTENTS/Resources"
cp "$BIN_DIR/FocusDive" "$MACOS/FocusDive"
cp "$ROOT/Resources/Info.plist" "$CONTENTS/Info.plist"
chmod +x "$MACOS/FocusDive"

codesign --force --deep --sign - "$APP"
printf 'Built %s\n' "$APP"
