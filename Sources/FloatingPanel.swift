import AppKit

final class FloatingPanel: NSPanel {

    init(frame: NSRect) {
        super.init(
            contentRect: frame,
            styleMask: [.resizable, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = false
        worksWhenModal = true
        isMovableByWindowBackground = true

        level = .floating

        var behavior: NSWindow.CollectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        if #available(macOS 14.0, *) { behavior.insert(.canJoinAllApplications) }
        collectionBehavior = behavior

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        minSize = NSSize(width: 200, height: 150)
    }

    override var canBecomeKey: Bool  { true }
    override var canBecomeMain: Bool { false }
}
