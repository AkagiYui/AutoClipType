import Foundation

enum InputMode: String, CaseIterable, Codable, Equatable, Identifiable {
    case physicalKeyboard
    case unicodeEvents

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .physicalKeyboard:
            "settings.inputMode.physicalKeyboard"
        case .unicodeEvents:
            "settings.inputMode.unicodeEvents"
        }
    }

    var descriptionKey: String {
        switch self {
        case .physicalKeyboard:
            "settings.inputMode.physicalKeyboard.description"
        case .unicodeEvents:
            "settings.inputMode.unicodeEvents.description"
        }
    }
}
