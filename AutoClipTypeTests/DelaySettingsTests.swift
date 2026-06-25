import XCTest
@testable import AutoClipType

final class DelaySettingsTests: XCTestCase {
    func testDefaultDelays() {
        XCTAssertEqual(DelaySettings.defaultCharacterDelay, 0.0, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.defaultStartDelay, 0.0, accuracy: 0.0001)
    }

    func testCharacterDelayClampsToSupportedRange() {
        XCTAssertEqual(DelaySettings.clampCharacterDelay(-1.0), 0.0, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampCharacterDelay(0.5), 0.5, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampCharacterDelay(10.0), 5.0, accuracy: 0.0001)
    }

    func testStartDelayClampsToSupportedRange() {
        XCTAssertEqual(DelaySettings.clampStartDelay(-1.0), 0.0, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampStartDelay(2.0), 2.0, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampStartDelay(10.0), 5.0, accuracy: 0.0001)
    }
}