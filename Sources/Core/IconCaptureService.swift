import AppKit
import CoreGraphics

/// Service to capture menu bar icon images
class IconCaptureService {
    static let shared = IconCaptureService()
    
    private var imageCache: [String: NSImage] = [:]
    
    private init() {}
    
    // MARK: - Public API
    
    /// Capture the icon at the given screen coordinates
    /// - Parameter frame: The CGRect of the icon in screen coordinates (from AXUIElement)
    /// - Returns: NSImage of the captured icon, or nil if capture failed
    func captureIcon(at frame: CGRect, forApp appOwner: String) -> NSImage? {
        // Check cache first
        let cacheKey = "\(appOwner)_\(Int(frame.origin.x))"
        if let cached = imageCache[cacheKey] {
            return cached
        }
        
        // Check permission
        guard PermissionsManager.shared.isScreenRecordingAllowed else {
            print("IconCapture: Screen Recording permission not granted")
            return nil
        }
        
        // AXUIElement and CGWindowListCreateImage both use top-left origin (Y=0 at top)
        // So we can use the frame directly
        let captureRect = frame
        
        // Debug: print what we're capturing
        print("IconCapture: Capturing \(appOwner) at \(captureRect)")
        
        // Capture the screen region
        guard let cgImage = CGWindowListCreateImage(
            captureRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.boundsIgnoreFraming]
        ) else {
            print("IconCapture: Failed to capture image at \(captureRect)")
            return nil
        }
        
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: frame.width, height: frame.height))
        
        // Cache it
        imageCache[cacheKey] = nsImage
        
        return nsImage
    }
    
    /// Clear the image cache (call when icons might have changed)
    func clearCache() {
        imageCache.removeAll()
    }
    
    /// Clear cache for a specific app
    func clearCache(forApp appOwner: String) {
        imageCache = imageCache.filter { !$0.key.hasPrefix(appOwner) }
    }
}
