import AppKit
import UserNotifications

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, UNUserNotificationCenterDelegate {
    private let services = AppServices.shared
    private var statusItem: NSStatusItem?
    private lazy var settingsWindowController = SettingsWindowController(services: services)

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        UNUserNotificationCenter.current().delegate = self
        services.appState.accessibilityTrusted = PermissionService.isAccessibilityTrusted
        createStatusItem()
        services.registerCurrentHotKey()
    }

    func applicationDidBecomeActive(_ notification: Notification) {
        services.appState.accessibilityTrusted = PermissionService.isAccessibilityTrusted
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    private func createStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(
            systemSymbolName: "keyboard",
            accessibilityDescription: String(localized: "app.menu.icon")
        )
        item.button?.image?.isTemplate = true

        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(
            title: String(localized: String.LocalizationValue(MenuCommandNames.settings)),
            action: #selector(openSettings),
            keyEquivalent: ","
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: String(localized: String.LocalizationValue(MenuCommandNames.quit)),
            action: #selector(quit),
            keyEquivalent: "q"
        ))
        item.menu = menu
        statusItem = item
    }

    func menuWillOpen(_ menu: NSMenu) {
    }

    @objc private func openSettings() {
        settingsWindowController.show()
    }

    @objc private func quit() {
        services.hotKeyRegistrar.unregister()
        NSApp.terminate(nil)
    }
}