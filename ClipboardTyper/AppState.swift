import Foundation
import Observation

@Observable
final class AppState {
    var isTyping = false
    var accessibilityTrusted = PermissionService.isAccessibilityTrusted
    var lastErrorMessage: String?
}