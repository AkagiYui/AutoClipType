import Carbon
import CoreGraphics
import Foundation

struct PhysicalKeyStroke: Equatable {
    let keyCode: CGKeyCode
    let usesShift: Bool
}

enum PhysicalKeyboardMapper {
    private static let unshifted: [Character: CGKeyCode] = [
        "a": CGKeyCode(kVK_ANSI_A),
        "b": CGKeyCode(kVK_ANSI_B),
        "c": CGKeyCode(kVK_ANSI_C),
        "d": CGKeyCode(kVK_ANSI_D),
        "e": CGKeyCode(kVK_ANSI_E),
        "f": CGKeyCode(kVK_ANSI_F),
        "g": CGKeyCode(kVK_ANSI_G),
        "h": CGKeyCode(kVK_ANSI_H),
        "i": CGKeyCode(kVK_ANSI_I),
        "j": CGKeyCode(kVK_ANSI_J),
        "k": CGKeyCode(kVK_ANSI_K),
        "l": CGKeyCode(kVK_ANSI_L),
        "m": CGKeyCode(kVK_ANSI_M),
        "n": CGKeyCode(kVK_ANSI_N),
        "o": CGKeyCode(kVK_ANSI_O),
        "p": CGKeyCode(kVK_ANSI_P),
        "q": CGKeyCode(kVK_ANSI_Q),
        "r": CGKeyCode(kVK_ANSI_R),
        "s": CGKeyCode(kVK_ANSI_S),
        "t": CGKeyCode(kVK_ANSI_T),
        "u": CGKeyCode(kVK_ANSI_U),
        "v": CGKeyCode(kVK_ANSI_V),
        "w": CGKeyCode(kVK_ANSI_W),
        "x": CGKeyCode(kVK_ANSI_X),
        "y": CGKeyCode(kVK_ANSI_Y),
        "z": CGKeyCode(kVK_ANSI_Z),
        "0": CGKeyCode(kVK_ANSI_0),
        "1": CGKeyCode(kVK_ANSI_1),
        "2": CGKeyCode(kVK_ANSI_2),
        "3": CGKeyCode(kVK_ANSI_3),
        "4": CGKeyCode(kVK_ANSI_4),
        "5": CGKeyCode(kVK_ANSI_5),
        "6": CGKeyCode(kVK_ANSI_6),
        "7": CGKeyCode(kVK_ANSI_7),
        "8": CGKeyCode(kVK_ANSI_8),
        "9": CGKeyCode(kVK_ANSI_9),
        " ": CGKeyCode(kVK_Space),
        "\t": CGKeyCode(kVK_Tab),
        "-": CGKeyCode(kVK_ANSI_Minus),
        "=": CGKeyCode(kVK_ANSI_Equal),
        "[": CGKeyCode(kVK_ANSI_LeftBracket),
        "]": CGKeyCode(kVK_ANSI_RightBracket),
        "\\": CGKeyCode(kVK_ANSI_Backslash),
        ";": CGKeyCode(kVK_ANSI_Semicolon),
        "'": CGKeyCode(kVK_ANSI_Quote),
        ",": CGKeyCode(kVK_ANSI_Comma),
        ".": CGKeyCode(kVK_ANSI_Period),
        "/": CGKeyCode(kVK_ANSI_Slash),
        "`": CGKeyCode(kVK_ANSI_Grave)
    ]

    private static let shifted: [Character: CGKeyCode] = [
        "A": CGKeyCode(kVK_ANSI_A),
        "B": CGKeyCode(kVK_ANSI_B),
        "C": CGKeyCode(kVK_ANSI_C),
        "D": CGKeyCode(kVK_ANSI_D),
        "E": CGKeyCode(kVK_ANSI_E),
        "F": CGKeyCode(kVK_ANSI_F),
        "G": CGKeyCode(kVK_ANSI_G),
        "H": CGKeyCode(kVK_ANSI_H),
        "I": CGKeyCode(kVK_ANSI_I),
        "J": CGKeyCode(kVK_ANSI_J),
        "K": CGKeyCode(kVK_ANSI_K),
        "L": CGKeyCode(kVK_ANSI_L),
        "M": CGKeyCode(kVK_ANSI_M),
        "N": CGKeyCode(kVK_ANSI_N),
        "O": CGKeyCode(kVK_ANSI_O),
        "P": CGKeyCode(kVK_ANSI_P),
        "Q": CGKeyCode(kVK_ANSI_Q),
        "R": CGKeyCode(kVK_ANSI_R),
        "S": CGKeyCode(kVK_ANSI_S),
        "T": CGKeyCode(kVK_ANSI_T),
        "U": CGKeyCode(kVK_ANSI_U),
        "V": CGKeyCode(kVK_ANSI_V),
        "W": CGKeyCode(kVK_ANSI_W),
        "X": CGKeyCode(kVK_ANSI_X),
        "Y": CGKeyCode(kVK_ANSI_Y),
        "Z": CGKeyCode(kVK_ANSI_Z),
        ")": CGKeyCode(kVK_ANSI_0),
        "!": CGKeyCode(kVK_ANSI_1),
        "@": CGKeyCode(kVK_ANSI_2),
        "#": CGKeyCode(kVK_ANSI_3),
        "$": CGKeyCode(kVK_ANSI_4),
        "%": CGKeyCode(kVK_ANSI_5),
        "^": CGKeyCode(kVK_ANSI_6),
        "&": CGKeyCode(kVK_ANSI_7),
        "*": CGKeyCode(kVK_ANSI_8),
        "(": CGKeyCode(kVK_ANSI_9),
        "_": CGKeyCode(kVK_ANSI_Minus),
        "+": CGKeyCode(kVK_ANSI_Equal),
        "{": CGKeyCode(kVK_ANSI_LeftBracket),
        "}": CGKeyCode(kVK_ANSI_RightBracket),
        "|": CGKeyCode(kVK_ANSI_Backslash),
        ":": CGKeyCode(kVK_ANSI_Semicolon),
        "\"": CGKeyCode(kVK_ANSI_Quote),
        "<": CGKeyCode(kVK_ANSI_Comma),
        ">": CGKeyCode(kVK_ANSI_Period),
        "?": CGKeyCode(kVK_ANSI_Slash),
        "~": CGKeyCode(kVK_ANSI_Grave)
    ]

    static func keyStroke(for text: String) -> PhysicalKeyStroke? {
        guard text.count == 1, let character = text.first else { return nil }
        if let keyCode = unshifted[character] {
            return PhysicalKeyStroke(keyCode: keyCode, usesShift: false)
        }
        if let keyCode = shifted[character] {
            return PhysicalKeyStroke(keyCode: keyCode, usesShift: true)
        }
        return nil
    }
}
