import AppKit
import SwiftUI

struct SettingsView: View {
    @Environment(\.settingsStore) private var settings
    @Environment(AppState.self) private var appState
    @State private var characterDelay = 0.1
    @State private var startDelay = 0.0
    @State private var hotKey = HotKey.defaultTrigger
    @State private var launchAtLogin = false
    @State private var inputMode = InputMode.physicalKeyboard

    var body: some View {
        Form {
            Section(String(localized: "settings.typing")) {
                Picker(String(localized: "settings.inputMode"), selection: $inputMode) {
                    ForEach(InputMode.allCases) { mode in
                        Text(String(localized: String.LocalizationValue(mode.titleKey)))
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: inputMode) { _, newValue in
                    settings.inputMode = newValue
                }

                Text(String(localized: String.LocalizationValue(inputMode.descriptionKey)))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                delayRow(
                    title: String(localized: "settings.characterDelay"),
                    value: delayBinding(
                        value: $characterDelay,
                        normalize: DelaySettings.clampCharacterDelay,
                        save: { settings.characterDelay = $0 }
                    ),
                    range: DelaySettings.characterDelayRange,
                    step: DelaySettings.characterDelayStep
                )

                delayRow(
                    title: String(localized: "settings.startDelay"),
                    value: delayBinding(
                        value: $startDelay,
                        normalize: DelaySettings.clampStartDelay,
                        save: { settings.startDelay = $0 }
                    ),
                    range: DelaySettings.startDelayRange,
                    step: DelaySettings.startDelayStep
                )
            }

            Section(String(localized: "settings.hotkey")) {
                HotKeyRecorderView(hotKey: $hotKey)
                    .frame(height: 30)
                    .onChange(of: hotKey) { _, newValue in
                        settings.hotKey = newValue
                        AppServices.shared.registerCurrentHotKey()
                    }

                Text("settings.hotkeyStopHint")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section(String(localized: "permissions.accessibility")) {
                HStack(spacing: 12) {
                    Image(systemName: appState.accessibilityTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(appState.accessibilityTrusted ? .green : .yellow)

                    Text(appState.accessibilityTrusted ? String(localized: "permissions.accessibility.granted") : String(localized: "permissions.accessibility.missing"))

                    Spacer()

                    Button(String(localized: "permissions.openSystemSettings")) {
                        PermissionService.openAccessibilitySettings()
                    }
                }
            }

            Section {
                Toggle(String(localized: "settings.launchAtLogin"), isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        settings.launchAtLogin = newValue
                        LoginItemService.setEnabled(newValue)
                    }
            } footer: {
                Text("settings.localOnlyHint")
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(
            minWidth: SettingsWindowLayout.minimumContentSize.width,
            idealWidth: SettingsWindowLayout.defaultContentSize.width,
            minHeight: SettingsWindowLayout.minimumContentSize.height,
            idealHeight: SettingsWindowLayout.defaultContentSize.height
        )
        .navigationTitle(String(localized: "settings.title"))
        .onAppear(perform: loadState)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            refreshPermissionState()
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didActivateApplicationNotification)) { _ in
            refreshPermissionState()
        }
    }

    private func delayRow(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .frame(width: 130, alignment: .leading)

            DelaySliderView(value: value, range: range, step: step)

            TextField(
                "",
                value: value,
                format: .number.precision(.fractionLength(0...2))
            )
            .labelsHidden()
            .textFieldStyle(.roundedBorder)
            .monospacedDigit()
            .frame(width: 76, alignment: .trailing)

            Text(String(localized: "settings.secondsUnit"))
                .foregroundStyle(.secondary)
        }
    }

    private func delayBinding(value: Binding<Double>, normalize: @escaping (Double) -> Double, save: @escaping (Double) -> Void) -> Binding<Double> {
        Binding(
            get: { value.wrappedValue },
            set: { proposedValue in
                var currentValue = value.wrappedValue
                guard DelayValueBinding.update(&currentValue, proposedValue: proposedValue, normalize: normalize) else {
                    return
                }
                value.wrappedValue = currentValue
                save(currentValue)
            }
        )
    }

    private func loadState() {
        characterDelay = settings.characterDelay
        startDelay = settings.startDelay
        hotKey = settings.hotKey
        launchAtLogin = settings.launchAtLogin
        inputMode = settings.inputMode
        refreshPermissionState()
    }

    private func refreshPermissionState() {
        appState.accessibilityTrusted = PermissionService.isAccessibilityTrusted
    }
}

#Preview {
    SettingsView()
        .environment(\.settingsStore, SettingsStore())
        .environment(AppState())
}

private struct SettingsStoreKey: EnvironmentKey {
    @MainActor static let defaultValue = SettingsStore()
}

extension EnvironmentValues {
    var settingsStore: SettingsStore {
        get { self[SettingsStoreKey.self] }
        set { self[SettingsStoreKey.self] = newValue }
    }
}