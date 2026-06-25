import Foundation

enum DelaySettings {
    nonisolated static let defaultCharacterDelay = 0.0
    nonisolated static let defaultStartDelay = 0.0
    nonisolated static let characterDelayRange = 0.0...5.0
    nonisolated static let startDelayRange = 0.0...5.0
    nonisolated static let characterDelayStep = 0.01
    nonisolated static let startDelayStep = 0.01

    nonisolated static func clampCharacterDelay(_ value: Double) -> Double {
        clamp(value, to: characterDelayRange)
    }

    nonisolated static func clampStartDelay(_ value: Double) -> Double {
        clamp(value, to: startDelayRange)
    }

    nonisolated private static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        let rounded = (value * 100).rounded() / 100
        return min(max(rounded, range.lowerBound), range.upperBound)
    }
}