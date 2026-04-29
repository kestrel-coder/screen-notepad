import AppKit
import SwiftUI

final class FloatingPanelController: NSWindowController {
    private var outsideMonitor: Any?

    init(settings: NotepadSettings, content: NotepadContent) {
        let frame = FloatingPanelController.restoreFrame()
        let panel = FloatingPanel(frame: frame)
        let hosting = NSHostingView(rootView: NotepadView(settings: settings, content: content))
        hosting.wantsLayer = true
        hosting.layer?.cornerRadius = 10
        hosting.layer?.masksToBounds = true
        panel.contentView = hosting
        super.init(window: panel)

        NotificationCenter.default.addObserver(
            self, selector: #selector(didMove),
            name: NSWindow.didMoveNotification, object: panel)
        NotificationCenter.default.addObserver(
            self, selector: #selector(didResize),
            name: NSWindow.didResizeNotification, object: panel)
    }

    required init?(coder: NSCoder) { nil }

    func toggle() {
        if window?.isVisible == true { hide() } else { show() }
    }

    func show() {
        window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKey()
        NotificationCenter.default.post(name: .notepadDidShow, object: nil)
        startMonitor()
    }

    func hide() {
        window?.orderOut(nil)
        stopMonitor()
    }

    private func startMonitor() {
        outsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            guard let self, let win = self.window else { return }
            if !win.frame.contains(NSEvent.mouseLocation) {
                DispatchQueue.main.async { self.hide() }
            }
        }
    }

    private func stopMonitor() {
        if let m = outsideMonitor { NSEvent.removeMonitor(m); outsideMonitor = nil }
    }

    @objc private func didMove()   { saveFrame() }
    @objc private func didResize() { saveFrame() }

    private func saveFrame() {
        guard let f = window?.frame else { return }
        let ud = UserDefaults.standard
        ud.set(f.origin.x, forKey: "notepad.window.x")
        ud.set(f.origin.y, forKey: "notepad.window.y")
        ud.set(f.width,    forKey: "notepad.window.w")
        ud.set(f.height,   forKey: "notepad.window.h")
    }

    private static func restoreFrame() -> NSRect {
        let ud = UserDefaults.standard
        let w = ud.object(forKey: "notepad.window.w") != nil ? ud.double(forKey: "notepad.window.w") : 360.0
        let h = ud.object(forKey: "notepad.window.h") != nil ? ud.double(forKey: "notepad.window.h") : 280.0
        let x = ud.double(forKey: "notepad.window.x")
        let y = ud.double(forKey: "notepad.window.y")
        guard x != 0 || y != 0 else {
            let sf = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
            return NSRect(x: sf.midX - w / 2, y: sf.midY - h / 2, width: w, height: h)
        }
        return NSRect(x: x, y: y, width: w, height: h)
    }
}
