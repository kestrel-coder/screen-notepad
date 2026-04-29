#!/bin/bash
set -e
cd "$(dirname "$0")"

SDK=$(xcrun --show-sdk-path --sdk macosx)
TARGET=arm64-apple-macosx13.0
APP=ScreenNotepad.app
VERSION="0.1.0"

echo "→ Cleaning..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

echo "→ Compiling..."
xcrun swiftc \
  -sdk "$SDK" \
  -target "$TARGET" \
  -framework AppKit \
  -framework SwiftUI \
  -framework Carbon \
  Sources/NotepadContent.swift \
  Sources/NotepadSettings.swift \
  Sources/HotkeyManager.swift \
  Sources/FloatingPanel.swift \
  Sources/FloatingPanelController.swift \
  Sources/NoteTextView.swift \
  Sources/NotepadView.swift \
  Sources/ToolbarView.swift \
  Sources/SettingsView.swift \
  Sources/AppDelegate.swift \
  Sources/main.swift \
  -o "$APP/Contents/MacOS/ScreenNotepad"

echo "→ Bundling..."
cp Info.plist "$APP/Contents/"
cp Resources/AppIcon.icns "$APP/Contents/Resources/"

echo "→ Signing..."
codesign --force --entitlements ScreenNotepad.entitlements -s - "$APP"

echo "→ Installing to /Applications..."
rm -rf "/Applications/$APP"
cp -r "$APP" /Applications/

if [[ "$1" == "--release" ]]; then
  echo "→ Packaging DMG..."
  STAGING=$(mktemp -d)
  cp -r "$APP" "$STAGING/"
  ln -s /Applications "$STAGING/Applications"
  DMG="ScreenNotepad-v${VERSION}.dmg"
  rm -f "$DMG"
  hdiutil create \
    -volname "ScreenNotepad" \
    -srcfolder "$STAGING" \
    -ov -format UDZO \
    "$DMG"
  rm -rf "$STAGING"
  echo "✓ DMG ready: $DMG"
fi

echo "✓ Done!  App installed to /Applications/$APP"
