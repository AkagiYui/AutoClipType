import XCTest
@testable import AutoClipType

final class InputModeTests: XCTestCase {
    func testDefaultInputModeIsPhysicalKeyboard() {
        XCTAssertEqual(SettingsDefaults.inputMode, .physicalKeyboard)
    }

    func testInputModeUsesStablePersistenceKey() {
        XCTAssertEqual(SettingsKeys.inputMode, "inputMode")
    }

    func testPhysicalKeyboardModeHasLocalizationKey() {
        XCTAssertEqual(InputMode.physicalKeyboard.titleKey, "settings.inputMode.physicalKeyboard")
    }

    func testUnicodeEventsModeHasLocalizationKey() {
        XCTAssertEqual(InputMode.unicodeEvents.titleKey, "settings.inputMode.unicodeEvents")
    }
}
