import AppKit
import Carbon

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FloatingPanelController!
    private var settingsWindowController: SettingsWindowController?
    private var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
        setupMenuBar()
        panelController = FloatingPanelController(
            settings: NotepadSettings.shared,
            content: NotepadContent.shared
        )
        registerHotkey()
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleOpenSettings),
            name: .openSettings, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleReregisterHotkey),
            name: .reregisterHotkey, object: nil)
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(
            systemSymbolName: "note.text",
            accessibilityDescription: "Screen Notepad"
        )
        let menu = NSMenu()
        let showItem = NSMenuItem(title: "显示/隐藏", action: #selector(togglePanel), keyEquivalent: "")
        showItem.target = self
        menu.addItem(showItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }

    private func registerHotkey() {
        let s = NotepadSettings.shared
        HotkeyManager.shared.register(keyCode: s.hotkeyCode, modifiers: s.hotkeyModifiers) { [weak self] in
            DispatchQueue.main.async { self?.togglePanel() }
        }
    }

    @objc func togglePanel() { panelController.toggle() }

    @objc private func handleOpenSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(settings: NotepadSettings.shared)
        }
        settingsWindowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func handleReregisterHotkey() { registerHotkey() }
}
