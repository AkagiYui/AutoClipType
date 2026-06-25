import XCTest
@testable import ClipboardTyper

final class TextTokenizerTests: XCTestCase {
    func testNewlineVariantsBecomeReturnTokens() {
        let tokens = TextTokenizer.tokens(for: "a\r\nb\rc\nd")

        XCTAssertEqual(tokens, [
            .text("a"),
            .returnKey,
            .text("b"),
            .returnKey,
            .text("c"),
            .returnKey,
            .text("d")
        ])
    }

    func testChineseAndEmojiArePreservedAsTextTokens() {
        let tokens = TextTokenizer.tokens(for: "你🙂好")

        XCTAssertEqual(tokens, [
            .text("你"),
            .text("🙂"),
            .text("好")
        ])
    }
}
