import AppKit
import SwiftUI

enum SettingsWindowLayout {
    static let defaultContentSize = NSSize(width: 560, height: 540)
    static let minimumContentSize = NSSize(width: 520, height: 420)
}

@MainActor
final class SettingsWindowController {
    private let services: AppServices
    private var window: NSWindow?

    init(services: AppServices) {
        self.services = services
    }

    func show() {
        if let window {
            NSApp.activate(ignoringOtherApps: true)
            window.makeKeyAndOrderFront(nil)
            return
        }

        let rootView = SettingsView()
            .environment(\.settingsStore, services.settingsStore)
            .environment(services.appState)

        let hostingController = NSHostingController(rootView: rootView)
        let window = NSWindow(contentViewController: hostingController)
        window.title = String(localized: "settings.title")
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.isReleasedWhenClosed = false
        window.contentMinSize = SettingsWindowLayout.minimumContentSize
        window.setContentSize(SettingsWindowLayout.defaultContentSize)
        window.center()

        self.window = window
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}