//
//  AutoClipTypeApp.swift
//  AutoClipType
//
//  Created by alya on 11/6/26.
//

import SwiftUI

@main
struct AutoClipTypeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let services = AppServices.shared

    var body: some Scene {
        Settings {
            SettingsView()
                .environment(\.settingsStore, services.settingsStore)
                .environment(services.appState)
        }
    }
}
