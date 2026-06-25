import AppKit
import SwiftUI

enum DelaySliderLayout {
    static let numberOfTickMarks = 0
}

struct DelaySliderView: NSViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value, step: step)
    }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider(value: value, minValue: range.lowerBound, maxValue: range.upperBound, target: context.coordinator, action: #selector(Coordinator.valueChanged(_:)))
        slider.numberOfTickMarks = DelaySliderLayout.numberOfTickMarks
        slider.allowsTickMarkValuesOnly = false
        slider.sliderType = .linear
        return slider
    }

    func updateNSView(_ nsView: NSSlider, context: Context) {
        nsView.minValue = range.lowerBound
        nsView.maxValue = range.upperBound
        nsView.doubleValue = value
        nsView.target = context.coordinator
        nsView.action = #selector(Coordinator.valueChanged(_:))
        context.coordinator.value = $value
        context.coordinator.step = step
    }

    final class Coordinator: NSObject {
        var value: Binding<Double>
        var step: Double

        init(value: Binding<Double>, step: Double) {
            self.value = value
            self.step = step
        }

        @objc func valueChanged(_ sender: NSSlider) {
            let stepped = (sender.doubleValue / step).rounded() * step
            value.wrappedValue = stepped
        }
    }
}
