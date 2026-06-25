import XCTest
@testable import ClipboardTyper

final class DelaySliderLayoutTests: XCTestCase {
    func testDelaySliderDoesNotShowTickMarks() {
        XCTAssertEqual(DelaySliderLayout.numberOfTickMarks, 0)
    }
}
