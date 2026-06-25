import Foundation

enum SettingsKeys {
    static let characterDelay = "characterDelay"
    static let startDelay = "startDelay"
    static let hotKey = "hotKey"
    static let launchAtLogin = "launchAtLogin"
    static let inputMode = "inputMode"
}

enum SettingsDefaults {
    static let inputMode = InputMode.physicalKeyboard
}
