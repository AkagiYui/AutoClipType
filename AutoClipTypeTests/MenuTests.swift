import XCTest
@testable import AutoClipType

final class MenuTests: XCTestCase {
    func testStatusMenuDoesNotExposeInputClipboardAction() {
        XCTAssertFalse(MenuCommandNames.all.contains("menu.inputClipboard"))
    }
}
