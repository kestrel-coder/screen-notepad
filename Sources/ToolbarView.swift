import SwiftUI
import AppKit

struct ToolbarView: View {
    @ObservedObject var settings: NotepadSettings
    @ObservedObject var content: NotepadContent

    var body: some View {
        HStack(spacing: 2) {
            IconButton(icon: "gearshape", help: "设置") {
                NotificationCenter.default.post(name: .openSettings, object: nil)
            }

            Spacer()

            IconButton(icon: "trash",           help: "清空内容")   { content.text = "" }
            IconButton(icon: "doc.on.doc",      help: "复制内容")   { copy(content.text) }
            IconButton(icon: "doc.on.doc.fill", help: "复制并清空") { copy(content.text); content.text = "" }
        }
        .foregroundColor(settings.textColor.opacity(0.75))
        .padding(.horizontal, 6)
    }

    private func copy(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }
}

private struct IconButton: View {
    let icon: String
    let help: String
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .frame(width: 22, height: 22)
        }
        .buttonStyle(HoverStyle(hovered: hovered))
        .onHover { hovered = $0 }
        .help(help)
    }
}

private struct HoverStyle: ButtonStyle {
    let hovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        configuration.isPressed
                            ? Color.primary.opacity(0.20)
                            : hovered ? Color.primary.opacity(0.10) : .clear
                    )
            )
            .animation(.easeOut(duration: 0.08), value: hovered)
            .animation(.easeOut(duration: 0.05), value: configuration.isPressed)
    }
}
