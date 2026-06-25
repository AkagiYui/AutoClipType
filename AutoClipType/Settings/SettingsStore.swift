import Foundation

@MainActor
final class SettingsStore {
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var characterDelay: Double {
        get {
            let stored = defaults.object(forKey: SettingsKeys.characterDelay) as? Double ?? DelaySettings.defaultCharacterDelay
            return DelaySettings.clampCharacterDelay(stored)
        }
        set {
            defaults.set(DelaySettings.clampCharacterDelay(newValue), forKey: SettingsKeys.characterDelay)
        }
    }

    var startDelay: Double {
        get {
            let stored = defaults.object(forKey: SettingsKeys.startDelay) as? Double ?? DelaySettings.defaultStartDelay
            return DelaySettings.clampStartDelay(stored)
        }
        set {
            defaults.set(DelaySettings.clampStartDelay(newValue), forKey: SettingsKeys.startDelay)
        }
    }

    var hotKey: HotKey {
        get {
            guard let data = defaults.data(forKey: SettingsKeys.hotKey),
                  let decoded = try? decoder.decode(HotKey.self, from: data),
                  decoded.isValid else {
                return .defaultTrigger
            }
            return decoded
        }
        set {
            let value = newValue.isValid ? newValue : HotKey.defaultTrigger
            if let data = try? encoder.encode(value) {
                defaults.set(data, forKey: SettingsKeys.hotKey)
            }
        }
    }

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: SettingsKeys.launchAtLogin) }
        set { defaults.set(newValue, forKey: SettingsKeys.launchAtLogin) }
    }

    var inputMode: InputMode {
        get {
            guard let rawValue = defaults.string(forKey: SettingsKeys.inputMode),
                  let mode = InputMode(rawValue: rawValue) else {
                return SettingsDefaults.inputMode
            }
            return mode
        }
        set {
            defaults.set(newValue.rawValue, forKey: SettingsKeys.inputMode)
        }
    }

}