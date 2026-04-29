# Screen Notepad — 实现计划

## 背景

用户需要一个通过全局快捷键唤起的 macOS 原生浮动打字板。问题根源：不同应用的回车键行为不一致（有些发送、有些换行），导致打字体验割裂。这个面板提供安全的草稿区，回车一律换行，写完再复制到目标输入框。

## 技术栈

- **语言**：Swift 5.x
- **UI**：SwiftUI + AppKit（NSPanel、NSVisualEffectView）
- **快捷键**：Carbon `RegisterEventHotKey`
- **构建**：CLT 命令行工具（无 Xcode）+ `build.sh` 脚本

## 项目结构

```
screen-notepad/
├── Sources/
│   ├── main.swift                    ← 入口
│   ├── AppDelegate.swift             ← 生命周期、菜单栏、通知
│   ├── FloatingPanel.swift           ← NSPanel 子类
│   ├── FloatingPanelController.swift ← 显示/隐藏、外部点击隐藏
│   ├── HotkeyManager.swift           ← Carbon 快捷键
│   ├── NotepadContent.swift          ← 文字内容（ObservableObject）
│   ├── NotepadSettings.swift         ← 设置（颜色/字体/快捷键）
│   ├── NotepadView.swift             ← 主视图 + VisualEffectBackground
│   ├── ToolbarView.swift             ← 底部工具栏
│   └── SettingsView.swift            ← 设置页 + SettingsWindowController
├── Info.plist
├── ScreenNotepad.entitlements
├── build.sh
└── plan.md                           ← 本文件
```

## 核心配置

### 浮动面板标志位（FloatingPanel.swift）

```
level = .floating
collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
styleMask = [.titled, .resizable, .nonactivatingPanel, .fullSizeContentView]
titleVisibility = .hidden
titlebarAppearsTransparent = true
isOpaque = false, backgroundColor = .clear
```

- `.canJoinAllSpaces` + `.fullScreenAuxiliary` = 在其他应用全屏时仍然可见
- `.nonactivatingPanel` = 不抢走其他应用的焦点
- `orderFrontRegardless()` = 显示时不激活本应用

### 快捷键（HotkeyManager.swift）

- 默认：F16（keyCode = 0x6A = 106，无修饰键）
- 使用 Carbon `RegisterEventHotKey`，全屏下有效，无需辅助功能权限
- 设置页支持录制新快捷键，保存到 UserDefaults 后重新注册

### 数据持久化（UserDefaults）

| 键名 | 类型 | 默认值 |
|------|------|--------|
| `notepad.content` | String | `""` |
| `notepad.bg.r/g/b/a` | Double | `0,0,0,0` (透明) |
| `notepad.text.r/g/b/a` | Double | `1,1,1,1` (白色) |
| `notepad.fontSize` | Double | `14` |
| `notepad.hotkey.keyCode` | Int | `106` (F16) |
| `notepad.hotkey.modifiers` | Int | `0` |
| `notepad.window.x/y/w/h` | Double | 屏幕居中，360×280 |

## 构建与运行

```bash
bash build.sh
open ScreenNotepad.app
```

## 验证清单

1. 按 F16 → 面板弹出，有半透明模糊背景
2. 输入文字，回车 → 换行，不发送
3. 点击面板外 → 面板隐藏，内容保留
4. 再按 F16 → 面板重现，内容完整
5. 其他应用全屏时按 F16 → 面板可见（不中断全屏）
6. 工具栏：清空 / 复制 / 复制并清空 均正常
7. 设置：改颜色/字体 → 面板实时更新
8. 设置里录制新快捷键 → 新键有效
9. 退出后重启 → 文字和设置完整恢复
10. 拖拽/缩放面板 → 下次打开位置一致
