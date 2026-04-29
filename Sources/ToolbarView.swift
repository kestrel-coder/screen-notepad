import SwiftUI
import AppKit

struct ToolbarView: View {
    @ObservedObject var settings: NotepadSettings
    @ObservedObject var content: NotepadContent

    var body: some View {
        HStack(spacing: 6) {
            Button {
                NotificationCenter.default.post(name: .openSettings, object: nil)
            } label: {
                Image(systemName: "gearshape")
                    .frame(width: 22, height: 22)
            }
            .help("设置")

            Spacer()

            Button {
                content.text = ""
            } label: {
                Image(systemName: "trash")
                    .frame(width: 22, height: 22)
            }
            .help("清空内容")

            Button {
                copy(content.text)
            } label: {
                Image(systemName: "doc.on.doc")
                    .frame(width: 22, height: 22)
            }
            .help("复制内容")

            Button {
                copy(content.text)
                content.text = ""
            } label: {
                Image(systemName: "doc.on.doc.fill")
                    .frame(width: 22, height: 22)
            }
            .help("复制并清空")
        }
        .buttonStyle(.borderless)
        .foregroundColor(settings.textColor.opacity(0.75))
        .padding(.horizontal, 10)
        // No background — transparent, blends with panel
    }

    private func copy(_ text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }
}
