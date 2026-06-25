import Foundation
import UserNotifications

final class NotificationService {
    private let center = UNUserNotificationCenter.current()
    private var requestedAuthorization = false

    func notifyImportantError(titleKey: String, bodyKey: String? = nil) {
        Task {
            let authorized = await ensureAuthorization()
            guard authorized else { return }

            let content = UNMutableNotificationContent()
            content.title = String(localized: String.LocalizationValue(titleKey))
            if let bodyKey {
                content.body = String(localized: String.LocalizationValue(bodyKey))
            }

            let request = UNNotificationRequest(
                identifier: "important-error-\(UUID().uuidString)",
                content: content,
                trigger: nil
            )
            try? await center.add(request)
        }
    }

    private func ensureAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            return true
        }

        if settings.authorizationStatus == .denied || requestedAuthorization {
            return false
        }

        requestedAuthorization = true
        return (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
    }
}