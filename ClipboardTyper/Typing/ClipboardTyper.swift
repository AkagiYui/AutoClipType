import AppKit
import Carbon
import CoreGraphics
import Foundation

@MainActor
final class ClipboardTyper {
    private let settings: SettingsStore
    private let appState: AppState
    private let notificationService: NotificationService
    private var typingTask: Task<Void, Never>?
    private var typingGeneration = 0

    init(settings: SettingsStore, appState: AppState, notificationService: NotificationService) {
        self.settings = settings
        self.appState = appState
        self.notificationService = notificationService
    }

    var isTyping: Bool {
        typingTask != nil
    }

    func startTypingFromClipboard() {
        guard typingTask == nil else { return }

        guard PermissionService.isAccessibilityTrusted else {
            appState.accessibilityTrusted = false
            appState.lastErrorMessage = String(localized: "notification.accessibilityMissing.title")
            notificationService.notifyImportantError(titleKey: "notification.accessibilityMissing.title")
            return
        }

        appState.accessibilityTrusted = true

        guard let text = NSPasteboard.general.string(forType: .string), !text.isEmpty else {
            appState.lastErrorMessage = String(localized: "notification.clipboardEmpty.title")
            notificationService.notifyImportantError(titleKey: "notification.clipboardEmpty.title")
            return
        }

        let tokens = TextTokenizer.tokens(for: text)
        let startDelay = settings.startDelay
        let characterDelay = settings.characterDelay
        let inputMode = settings.inputMode
        typingGeneration += 1
        let generation = typingGeneration

        appState.isTyping = true
        typingTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: UInt64(startDelay * 1_000_000_000))
                for token in tokens {
                    try Task.checkCancellation()
                    Self.post(token, inputMode: inputMode)
                    try await Task.sleep(nanoseconds: UInt64(characterDelay * 1_000_000_000))
                }
            } catch {
            }

            await MainActor.run {
                guard self?.typingGeneration == generation else { return }
                self?.typingTask = nil
                self?.appState.isTyping = false
            }
        }
    }

    func stopTyping() {
        typingGeneration += 1
        typingTask?.cancel()
        typingTask = nil
        appState.isTyping = false
    }

    private static func post(_ token: TextToken, inputMode: InputMode) {
        switch token {
        case .returnKey:
            postReturn()
        case .text(let text):
            switch inputMode {
            case .physicalKeyboard:
                postPhysical(text)
            case .unicodeEvents:
                postUnicode(text)
            }
        }
    }

    private static func postReturn() {
        guard let source = CGEventSource(stateID: .hidSystemState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Return), keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: CGKeyCode(kVK_Return), keyDown: false) else {
            return
        }

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }

    private static func postUnicode(_ text: String) {
        guard let source = CGEventSource(stateID: .hidSystemState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false) else {
            return
        }

        let utf16 = Array(text.utf16)
        utf16.withUnsafeBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            keyDown.keyboardSetUnicodeString(stringLength: buffer.count, unicodeString: baseAddress)
            keyUp.keyboardSetUnicodeString(stringLength: buffer.count, unicodeString: baseAddress)
        }

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }

    private static func postPhysical(_ text: String) {
        guard let stroke = PhysicalKeyboardMapper.keyStroke(for: text),
              let source = CGEventSource(stateID: .hidSystemState) else {
            return
        }

        if stroke.usesShift {
            postKey(CGKeyCode(kVK_Shift), keyDown: true, source: source)
        }
        postKey(stroke.keyCode, keyDown: true, source: source)
        postKey(stroke.keyCode, keyDown: false, source: source)
        if stroke.usesShift {
            postKey(CGKeyCode(kVK_Shift), keyDown: false, source: source)
        }
    }

    private static func postKey(_ keyCode: CGKeyCode, keyDown: Bool, source: CGEventSource) {
        guard let event = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: keyDown) else {
            return
        }
        event.post(tap: .cghidEventTap)
    }
}