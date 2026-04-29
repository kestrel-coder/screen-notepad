import AppKit
import SwiftUI

struct NoteTextView: NSViewRepresentable {
    @Binding var text: String
    var fontSize: CGFloat
    var textColor: NSColor

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else { return scrollView }

        textView.delegate = context.coordinator
        context.coordinator.textView = textView

        textView.isRichText = false
        textView.importsGraphics = false
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.usesFontPanel = false
        textView.usesRuler = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.textContainerInset = NSSize(width: 10, height: 10)

        scrollView.backgroundColor = .clear
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder

        textView.string = text
        applyAttrs(to: textView)

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.handleDidShow),
            name: .notepadDidShow, object: nil)

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        // Sync text only when changed externally (e.g., clear button)
        if textView.string != text {
            textView.string = text
        }

        // Always keep typing attributes current
        textView.typingAttributes = makeAttrs()
        textView.insertionPointColor = textColor

        // Re-apply to existing text only when settings actually changed
        let coord = context.coordinator
        if coord.lastFontSize != fontSize || !coord.lastTextColor.isEqual(textColor) {
            coord.lastFontSize = fontSize
            coord.lastTextColor = textColor
            if let storage = textView.textStorage, storage.length > 0 {
                textView.undoManager?.disableUndoRegistration()
                storage.beginEditing()
                storage.setAttributes(makeAttrs(), range: NSRange(location: 0, length: storage.length))
                storage.endEditing()
                textView.undoManager?.enableUndoRegistration()
            }
        }
    }

    private func makeAttrs() -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        return [
            .font: NSFont.systemFont(ofSize: fontSize),
            .foregroundColor: textColor,
            .paragraphStyle: style,
        ]
    }

    private func applyAttrs(to textView: NSTextView) {
        let attrs = makeAttrs()
        textView.typingAttributes = attrs
        textView.insertionPointColor = textColor
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var parent: NoteTextView
        weak var textView: NSTextView?
        var lastFontSize: CGFloat = -1
        var lastTextColor: NSColor = .white

        init(_ parent: NoteTextView) { self.parent = parent }

        deinit { NotificationCenter.default.removeObserver(self) }

        func textDidChange(_ notification: Notification) {
            guard let tv = notification.object as? NSTextView else { return }
            parent.text = tv.string
        }

        @objc func handleDidShow() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let tv = self?.textView else { return }
                tv.window?.makeFirstResponder(tv)
            }
        }
    }
}
