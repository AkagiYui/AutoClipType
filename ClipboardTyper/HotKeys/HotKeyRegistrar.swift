import Carbon
import Foundation

final class HotKeyRegistrar {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var onTrigger: (() -> Void)?

    func register(_ hotKey: HotKey, onTrigger triggerHandler: @escaping () -> Void) {
        unregister()
        guard hotKey.isValid else { return }
        onTrigger = triggerHandler

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        let installStatus = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else { return noErr }
                let registrar = Unmanaged<HotKeyRegistrar>.fromOpaque(userData).takeUnretainedValue()
                registrar.onTrigger?()
                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandlerRef
        )
        guard installStatus == noErr else {
            NSLog("Failed to install hotkey handler: \(installStatus)")
            eventHandlerRef = nil
            self.onTrigger = nil
            return
        }

        let hotKeyID = EventHotKeyID(signature: OSType(0x43545950), id: 1)
        let registerStatus = RegisterEventHotKey(
            hotKey.keyCode,
            hotKey.carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard registerStatus == noErr else {
            NSLog("Failed to register hotkey: \(registerStatus)")
            unregister()
            return
        }
    }

    func unregister() {
        if let hotKeyRef {
            let status = UnregisterEventHotKey(hotKeyRef)
            if status != noErr {
                NSLog("Failed to unregister hotkey: \(status)")
            }
            self.hotKeyRef = nil
        }
        if let eventHandlerRef {
            let status = RemoveEventHandler(eventHandlerRef)
            if status != noErr {
                NSLog("Failed to remove hotkey handler: \(status)")
            }
            self.eventHandlerRef = nil
        }
        onTrigger = nil
    }

    deinit {
        unregister()
    }
}