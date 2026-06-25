import XCTest
@testable import AutoClipType

final class SettingsWindowLayoutTests: XCTestCase {
    func testDefaultContentSizeIsTallEnoughForSettingsForm() {
        XCTAssertGreaterThanOrEqual(SettingsWindowLayout.defaultContentSize.width, 520)
        XCTAssertGreaterThanOrEqual(SettingsWindowLayout.defaultContentSize.height, 520)
        XCTAssertGreaterThanOrEqual(SettingsWindowLayout.minimumContentSize.width, 520)
        XCTAssertGreaterThanOrEqual(SettingsWindowLayout.minimumContentSize.height, 420)
    }
}
