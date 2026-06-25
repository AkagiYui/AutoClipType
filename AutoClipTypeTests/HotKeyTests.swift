import XCTest
import Carbon
@testable import AutoClipType

final class HotKeyTests: XCTestCase {
    func testDefaultHotKeyIsControlOptionV() {
        let hotKey = HotKey.defaultTrigger

        XCTAssertEqual(hotKey.keyCode, 9)
        XCTAssertEqual(hotKey.modifiers, [.control, .option])
        XCTAssertEqual(hotKey.displayString, "⌃⌥V")
    }

    func testHotKeyRequiresAtLeastOneModifier() {
        XCTAssertFalse(HotKey(keyCode: 9, modifiers: []).isValid)
        XCTAssertTrue(HotKey(keyCode: 9, modifiers: [.command]).isValid)
        XCTAssertTrue(HotKey(keyCode: 9, modifiers: [.control, .option, .shift]).isValid)
    }

    func testStandaloneFunctionKeyIsValid() {
        let hotKey = HotKey(keyCode: UInt32(kVK_F7), modifiers: [])

        XCTAssertTrue(hotKey.isValid)
        XCTAssertEqual(hotKey.displayString, "F7")
    }
}
