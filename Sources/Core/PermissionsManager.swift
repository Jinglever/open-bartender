import Foundation
import ApplicationServices

class PermissionsManager {
    static let shared = PermissionsManager()
    
    var isAccessibilityTrusted: Bool {
        return AXIsProcessTrusted()
    }
    
    func promptForAccessibility() {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String : true]
        AXIsProcessTrustedWithOptions(options)
    }
}
