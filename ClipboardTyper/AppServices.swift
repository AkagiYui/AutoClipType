import Foundation

@MainActor
final class AppServices {
    static let shared = AppServices()

    let settingsStore = SettingsStore()
    let appState = AppState()
    let notificationService = NotificationService()
    let hotKeyRegistrar = HotKeyRegistrar()

    lazy var clipboardTyper = ClipboardTyper(
        settings: settingsStore,
        appState: appState,
        notificationService: notificationService
    )

    private init() {}

    func registerCurrentHotKey() {
        hotKeyRegistrar.register(settingsStore.hotKey) {
            Task { @MainActor in
                AppServices.shared.handleHotKeyTrigger()
            }
        }
    }

    func handleHotKeyTrigger() {
        if clipboardTyper.isTyping {
            clipboardTyper.stopTyping()
        } else {
            clipboardTyper.startTypingFromClipboard()
        }
    }
}