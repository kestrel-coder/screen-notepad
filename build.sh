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
codesign --force --deep --entitlements ScreenNotepad.entitlements -s - "$APP"

echo "→ Installing to /Applications..."
rm -rf "/Applications/$APP"
cp -r "$APP" /Applications/

if [[ "$1" == "--release" ]]; then
  echo "→ Packaging DMG..."
  DMG="ScreenNotepad-v${VERSION}.dmg"
  STAGING=$(mktemp -d)

  cp -r "$APP" "$STAGING/"
  ln -s /Applications "$STAGING/Applications"

  # Instructions file for users who get Gatekeeper blocked
  cat > "$STAGING/安装说明 How to Install.txt" << 'EOF'
ScreenNotepad v0.1.0 安装说明
================================

1. 将 ScreenNotepad.app 拖入右侧的 Applications（应用程序）文件夹

2. 第一次打开时，macOS 可能提示「无法打开，因为无法验证开发者」
   解决方法：
   → 在 Finder 中找到 ScreenNotepad.app
   → 按住 Control 键，单击 App 图标
   → 选择「打开」
   → 在弹出对话框中再次点击「打开」

3. 之后每次正常双击打开即可

使用说明：
- 按 F16 键呼出/隐藏悬浮记事本（需在系统偏好设置中授权辅助功能）
- 记事本始终浮于其他窗口之上

系统要求：macOS 13.0+ (Apple Silicon, M1/M2/M3/M4)

================================
How to Install (English)

1. Drag ScreenNotepad.app to the Applications folder on the right.

2. First launch: macOS may say "cannot be opened because developer cannot be verified."
   Fix: In Finder, right-click (Control+click) the app → Open → Open

3. After that, double-click to open normally.

Requirements: macOS 13.0+ (Apple Silicon only)
EOF

  rm -f "$DMG"
  hdiutil create \
    -volname "ScreenNotepad v${VERSION}" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "$DMG"

  rm -rf "$STAGING"

  # Verify the DMG
  hdiutil verify "$DMG" > /dev/null
  echo "✓ DMG ready: $DMG ($(du -sh "$DMG" | cut -f1))"
fi

echo "✓ Done!  App installed to /Applications/$APP"
