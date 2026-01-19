import Foundation
import ApplicationServices
import CoreGraphics

class PermissionsManager {
    static let shared = PermissionsManager()
    
    // MARK: - Accessibility Permission
    
    var isAccessibilityTrusted: Bool {
        return AXIsProcessTrusted()
    }
    
    func promptForAccessibility() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        AXIsProcessTrustedWithOptions(options)
    }
    
    // MARK: - Screen Recording Permission
    
    var isScreenRecordingAllowed: Bool {
        // Try to capture a 1x1 pixel - if it fails, we don't have permission
        if #available(macOS 10.15, *) {
            return CGPreflightScreenCaptureAccess()
        }
        // Pre-Catalina always allowed
        return true
    }
    
    func requestScreenRecordingPermission() {
        if #available(macOS 10.15, *) {
            // This will prompt the user if not already granted
            CGRequestScreenCaptureAccess()
        }
    }
    
    // MARK: - Combined Check
    
    var hasAllPermissions: Bool {
        return isAccessibilityTrusted && isScreenRecordingAllowed
    }
}
