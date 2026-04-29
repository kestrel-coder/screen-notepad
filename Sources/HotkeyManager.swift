import Carbon.HIToolbox

private var _hotkeyAction: (() -> Void)?
private var _hotkeyRef: EventHotKeyRef?
private var _eventHandlerRef: EventHandlerRef?
private var _handlerInstalled = false

final class HotkeyManager {
    static let shared = HotkeyManager()
    private init() {}

    func register(keyCode: Int, modifiers: Int, action: @escaping () -> Void) {
        if let ref = _hotkeyRef { UnregisterEventHotKey(ref); _hotkeyRef = nil }
        _hotkeyAction = action

        if !_handlerInstalled {
            var spec = EventTypeSpec(
                eventClass: UInt32(kEventClassKeyboard),
                eventKind:  UInt32(kEventHotKeyPressed)
            )
            let callback: EventHandlerUPP = { (_, _, _) -> OSStatus in
                _hotkeyAction?()
                return noErr
            }
            InstallEventHandler(
                GetApplicationEventTarget(),
                callback,
                1, &spec,
                nil,
                &_eventHandlerRef
            )
            _handlerInstalled = true
        }

        let id = EventHotKeyID(signature: OSType(0x534E_5044), id: 1)
        RegisterEventHotKey(
            UInt32(keyCode), UInt32(modifiers),
            id, GetApplicationEventTarget(),
            0, &_hotkeyRef
        )
    }

    func unregister() {
        if let ref = _hotkeyRef { UnregisterEventHotKey(ref); _hotkeyRef = nil }
    }
}
