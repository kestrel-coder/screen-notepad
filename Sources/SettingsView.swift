import SwiftUI
import AppKit
import Carbon.HIToolbox

struct SettingsView: View {
    @ObservedObject var settings: NotepadSettings
    @State private var isRecording = false
    @State private var keyMonitor: Any?

    var body: some View {
        Form {
            Section("外观") {
                ColorPicker("背景颜色", selection: $settings.backgroundColor, supportsOpacity: true)
                ColorPicker("文字颜色", selection: $settings.textColor)
                HStack {
                    Text("字体大小")
                    Slider(value: $settings.fontSize, in: 10...32, step: 1)
                    Text("\(Int(settings.fontSize))pt")
                        .monospacedDigit()
                        .frame(width: 40, alignment: .trailing)
                }
            }

            Section("快捷键") {
                HStack {
                    Text("唤起快捷键")
                    Spacer()
                    Button(isRecording ? "按下新快捷键..." : shortcutLabel) {
                        isRecording ? stopRecording() : startRecording()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(isRecording ? .red : .primary)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 380, height: 280)
        .onDisappear { stopRecording() }
    }

    private var shortcutLabel: String {
        shortcutString(keyCode: settings.hotkeyCode, carbonMods: settings.hotkeyModifiers)
    }

    private func startRecording() {
        isRecording = true
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard self.isRecording else { return event }
            if Int(event.keyCode) == kVK_Escape { self.stopRecording(); return nil }
            self.settings.hotkeyCode      = Int(event.keyCode)
            self.settings.hotkeyModifiers = Int(event.modifierFlags.carbonModifiers)
            NotificationCenter.default.post(name: .reregisterHotkey, object: nil)
            self.stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        isRecording = false
        if let m = keyMonitor { NSEvent.removeMonitor(m); keyMonitor = nil }
    }
}

private extension NSEvent.ModifierFlags {
    var carbonModifiers: UInt32 {
        var r: UInt32 = 0
        if contains(.command) { r |= UInt32(cmdKey) }
        if contains(.option)  { r |= UInt32(optionKey) }
        if contains(.shift)   { r |= UInt32(shiftKey) }
        if contains(.control) { r |= UInt32(controlKey) }
        return r
    }
}

private func shortcutString(keyCode: Int, carbonMods: Int) -> String {
    let m = UInt32(carbonMods)
    var s = ""
    if m & UInt32(controlKey) != 0 { s += "⌃" }
    if m & UInt32(optionKey)  != 0 { s += "⌥" }
    if m & UInt32(shiftKey)   != 0 { s += "⇧" }
    if m & UInt32(cmdKey)     != 0 { s += "⌘" }
    s += keyCodeName(keyCode)
    return s
}

private func keyCodeName(_ code: Int) -> String {
    let names: [Int: String] = [
        kVK_ANSI_A: "A", kVK_ANSI_B: "B", kVK_ANSI_C: "C", kVK_ANSI_D: "D",
        kVK_ANSI_E: "E", kVK_ANSI_F: "F", kVK_ANSI_G: "G", kVK_ANSI_H: "H",
        kVK_ANSI_I: "I", kVK_ANSI_J: "J", kVK_ANSI_K: "K", kVK_ANSI_L: "L",
        kVK_ANSI_M: "M", kVK_ANSI_N: "N", kVK_ANSI_O: "O", kVK_ANSI_P: "P",
        kVK_ANSI_Q: "Q", kVK_ANSI_R: "R", kVK_ANSI_S: "S", kVK_ANSI_T: "T",
        kVK_ANSI_U: "U", kVK_ANSI_V: "V", kVK_ANSI_W: "W", kVK_ANSI_X: "X",
        kVK_ANSI_Y: "Y", kVK_ANSI_Z: "Z",
        kVK_F1: "F1",   kVK_F2: "F2",   kVK_F3: "F3",   kVK_F4: "F4",
        kVK_F5: "F5",   kVK_F6: "F6",   kVK_F7: "F7",   kVK_F8: "F8",
        kVK_F9: "F9",   kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12",
        kVK_F13: "F13", kVK_F14: "F14", kVK_F15: "F15", kVK_F16: "F16",
        kVK_F17: "F17", kVK_F18: "F18", kVK_F19: "F19", kVK_F20: "F20",
        kVK_Space: "Space", kVK_Return: "↩", kVK_Tab: "⇥",
        kVK_Delete: "⌫",    kVK_Escape: "⎋",
    ]
    return names[code] ?? "Key\(code)"
}

final class SettingsWindowController: NSWindowController {
    init(settings: NotepadSettings) {
        let view = SettingsView(settings: settings)
        let hosting = NSHostingView(rootView: view)
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "设置"
        win.contentView = hosting
        win.center()
        super.init(window: win)
    }
    required init?(coder: NSCoder) { nil }
}
