import XCTest
@testable import ClipboardTyper

final class MenuTests: XCTestCase {
    func testStatusMenuDoesNotExposeInputClipboardAction() {
        XCTAssertFalse(MenuCommandNames.all.contains("menu.inputClipboard"))
    }
}
