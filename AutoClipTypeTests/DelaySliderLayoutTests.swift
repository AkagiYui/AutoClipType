import XCTest
@testable import AutoClipType

final class DelaySliderLayoutTests: XCTestCase {
    func testDelaySliderDoesNotShowTickMarks() {
        XCTAssertEqual(DelaySliderLayout.numberOfTickMarks, 0)
    }
}
