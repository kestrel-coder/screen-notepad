import Foundation
import SwiftUI
import AppKit

final class NotepadSettings: ObservableObject {
    static let shared = NotepadSettings()

    @Published var backgroundColor: Color {
        didSet { saveColor(backgroundColor, prefix: "notepad.bg") }
    }
    @Published var textColor: Color {
        didSet { saveColor(textColor, prefix: "notepad.text") }
    }
    @Published var fontSize: Double {
        didSet { UserDefaults.standard.set(fontSize, forKey: "notepad.fontSize") }
    }
    @Published var hotkeyCode: Int {
        didSet { UserDefaults.standard.set(hotkeyCode, forKey: "notepad.hotkey.keyCode") }
    }
    @Published var hotkeyModifiers: Int {
        didSet { UserDefaults.standard.set(hotkeyModifiers, forKey: "notepad.hotkey.modifiers") }
    }

    private init() {
        let ud = UserDefaults.standard
        fontSize        = ud.object(forKey: "notepad.fontSize") != nil ? ud.double(forKey: "notepad.fontSize") : 14
        hotkeyCode      = ud.object(forKey: "notepad.hotkey.keyCode") != nil ? ud.integer(forKey: "notepad.hotkey.keyCode") : 106 // kVK_F16
        hotkeyModifiers = ud.integer(forKey: "notepad.hotkey.modifiers")
        backgroundColor = Self.loadColor(prefix: "notepad.bg",   fallback: .clear)
        textColor       = Self.loadColor(prefix: "notepad.text",  fallback: .white)
    }

    private func saveColor(_ color: Color, prefix: String) {
        guard let srgb = NSColor(color).usingColorSpace(.sRGB) else { return }
        let ud = UserDefaults.standard
        ud.set(Double(srgb.redComponent),   forKey: "\(prefix).r")
        ud.set(Double(srgb.greenComponent), forKey: "\(prefix).g")
        ud.set(Double(srgb.blueComponent),  forKey: "\(prefix).b")
        ud.set(Double(srgb.alphaComponent), forKey: "\(prefix).a")
    }

    private static func loadColor(prefix: String, fallback: Color) -> Color {
        let ud = UserDefaults.standard
        guard ud.object(forKey: "\(prefix).r") != nil else { return fallback }
        return Color(
            red:     ud.double(forKey: "\(prefix).r"),
            green:   ud.double(forKey: "\(prefix).g"),
            blue:    ud.double(forKey: "\(prefix).b"),
            opacity: ud.double(forKey: "\(prefix).a")
        )
    }
}
