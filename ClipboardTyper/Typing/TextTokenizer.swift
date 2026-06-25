import Foundation

enum TextTokenizer {
    static func tokens(for text: String) -> [TextToken] {
        var tokens: [TextToken] = []
        var currentText = ""
        var scalarIterator = text.unicodeScalars.makeIterator()

        while let scalar = scalarIterator.next() {
            if scalar == "\r" {
                flush(&currentText, into: &tokens)

                if let nextScalar = scalarIterator.next(), nextScalar != "\n" {
                    currentText.append(String(nextScalar))
                }
                tokens.append(.returnKey)
                continue
            }

            if scalar == "\n" {
                flush(&currentText, into: &tokens)
                tokens.append(.returnKey)
                continue
            }

            currentText.append(String(scalar))
        }

        flush(&currentText, into: &tokens)

        return tokens
    }

    private static func flush(_ text: inout String, into tokens: inout [TextToken]) {
        guard !text.isEmpty else { return }
        for character in text {
            tokens.append(.text(String(character)))
        }
        text.removeAll(keepingCapacity: true)
    }
}