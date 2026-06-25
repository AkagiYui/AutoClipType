import XCTest
@testable import AutoClipType

final class DelayValueBindingTests: XCTestCase {
    func testUpdateOnlyReportsChangeWhenNormalizedValueDiffers() {
        var value = 0.01

        XCTAssertFalse(DelayValueBinding.update(&value, proposedValue: 0.014, normalize: DelaySettings.clampCharacterDelay))
        XCTAssertEqual(value, 0.01, accuracy: 0.0001)

        XCTAssertTrue(DelayValueBinding.update(&value, proposedValue: 0.019, normalize: DelaySettings.clampCharacterDelay))
        XCTAssertEqual(value, 0.02, accuracy: 0.0001)
    }
}
