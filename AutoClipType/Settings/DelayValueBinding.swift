import Foundation

enum DelayValueBinding {
    static func update(_ currentValue: inout Double, proposedValue: Double, normalize: (Double) -> Double) -> Bool {
        let normalizedValue = normalize(proposedValue)
        guard normalizedValue != currentValue else { return false }
        currentValue = normalizedValue
        return true
    }
}
