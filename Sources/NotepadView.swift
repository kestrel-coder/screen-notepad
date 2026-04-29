import SwiftUI
import AppKit

extension Notification.Name {
    static let notepadDidShow   = Notification.Name("com.screenpad.notepadDidShow")
    static let openSettings     = Notification.Name("com.screenpad.openSettings")
    static let reregisterHotkey = Notification.Name("com.screenpad.reregisterHotkey")
}

struct NotepadView: View {
    @ObservedObject var settings: NotepadSettings
    @ObservedObject var content: NotepadContent

    var body: some View {
        ZStack {
            // Layer 1: native blur
            VisualEffectBackground()
                .ignoresSafeArea()

            // Layer 2: fixed opacity boost (makes it less transparent)
            Color.black.opacity(0.28)
                .ignoresSafeArea()

            // Layer 3: user-customizable color overlay
            settings.backgroundColor
                .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                NoteTextView(
                    text: $content.text,
                    fontSize: CGFloat(settings.fontSize),
                    textColor: NSColor(settings.textColor)
                )

                Divider().opacity(0.15)

                ToolbarView(settings: settings, content: content)
                    .frame(height: 36)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Visual Effect

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .hudWindow
        v.blendingMode = .behindWindow
        v.state = .active
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
