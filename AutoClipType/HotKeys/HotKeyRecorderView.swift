import AppKit
import SwiftUI

struct HotKeyRecorderView: NSViewRepresentable {
    @Binding var hotKey: HotKey

    func makeNSView(context: Context) -> RecorderControl {
        let control = RecorderControl()
        control.onHotKey = { captured in
            if captured.isValid {
                hotKey = captured
            }
        }
        control.displayString = hotKey.displayString
        return control
    }

    func updateNSView(_ nsView: RecorderControl, context: Context) {
        nsView.displayString = hotKey.displayString
    }
}

final class RecorderControl: NSStackView {
    var onHotKey: ((HotKey) -> Void)? {
        didSet { field.onHotKey = onHotKey }
    }

    var displayString: String {
        get { field.stringValue }
        set { field.stringValue = newValue }
    }

    private let field = RecorderTextField()
    private let button = NSButton(title: String(localized: "settings.recordHotkey"), target: nil, action: nil)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        orientation = .horizontal
        spacing = 8
        alignment = .centerY

        field.alignment = .center
        field.isEditable = false
        field.isSelectable = false
        field.bezelStyle = .roundedBezel
        field.placeholderString = String(localized: "settings.recordHotkey")

        button.target = self
        button.action = #selector(beginRecording)

        addArrangedSubview(field)
        addArrangedSubview(button)
        field.widthAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func beginRecording() {
        field.stringValue = String(localized: "settings.recordingHotkey")
        window?.makeFirstResponder(field)
    }
}

final class RecorderTextField: NSTextField {
    var onHotKey: ((HotKey) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        let captured = HotKey.fromNSEvent(keyCode: event.keyCode, modifierFlags: event.modifierFlags)
        if captured.isValid {
            onHotKey?(captured)
        }
    }
}