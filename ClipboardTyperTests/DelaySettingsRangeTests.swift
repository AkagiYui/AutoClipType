import XCTest
@testable import ClipboardTyper

final class DelaySettingsRangeTests: XCTestCase {
    func testCharacterDelaySupportsZeroSeconds() {
        XCTAssertEqual(DelaySettings.defaultCharacterDelay, 0.0, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.characterDelayRange.lowerBound, 0.0, accuracy: 0.0001)
    }

    func testCharacterDelayClampsToHundredthPrecisionRange() {
        XCTAssertEqual(DelaySettings.clampCharacterDelay(-1.0), 0.0, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampCharacterDelay(0.005), 0.01, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampCharacterDelay(0.014), 0.01, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampCharacterDelay(0.019), 0.02, accuracy: 0.0001)
        XCTAssertEqual(DelaySettings.clampCharacterDelay(10.0), 5.0, accuracy: 0.0001)
    }
}
