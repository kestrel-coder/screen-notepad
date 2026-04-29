#!/bin/bash
set -e
cd "$(dirname "$0")"

SDK=$(xcrun --show-sdk-path --sdk macosx)
TARGET=arm64-apple-macosx13.0
APP=ScreenNotepad.app

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

echo "→ Signing..."
codesign --force --entitlements ScreenNotepad.entitlements -s - "$APP"

echo "✓ Done!  Run: open $APP"
