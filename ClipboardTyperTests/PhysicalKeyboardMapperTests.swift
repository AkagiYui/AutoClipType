import XCTest
import Carbon
@testable import ClipboardTyper

final class PhysicalKeyboardMapperTests: XCTestCase {
    func testLowercaseLetterMapsToPhysicalKeyWithoutShift() {
        XCTAssertEqual(PhysicalKeyboardMapper.keyStroke(for: "a"), PhysicalKeyStroke(keyCode: CGKeyCode(kVK_ANSI_A), usesShift: false))
    }

    func testUppercaseLetterMapsToPhysicalKeyWithShift() {
        XCTAssertEqual(PhysicalKeyboardMapper.keyStroke(for: "A"), PhysicalKeyStroke(keyCode: CGKeyCode(kVK_ANSI_A), usesShift: true))
    }

    func testShiftedSymbolMapsToPhysicalKeyWithShift() {
        XCTAssertEqual(PhysicalKeyboardMapper.keyStroke(for: "!"), PhysicalKeyStroke(keyCode: CGKeyCode(kVK_ANSI_1), usesShift: true))
    }

    func testSpaceMapsToPhysicalSpaceKey() {
        XCTAssertEqual(PhysicalKeyboardMapper.keyStroke(for: " "), PhysicalKeyStroke(keyCode: CGKeyCode(kVK_Space), usesShift: false))
    }

    func testUnsupportedCharacterDoesNotMapToPhysicalKey() {
        XCTAssertNil(PhysicalKeyboardMapper.keyStroke(for: "你"))
    }
}