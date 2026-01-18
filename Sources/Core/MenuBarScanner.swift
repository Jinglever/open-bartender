import Foundation
import Cocoa
import ApplicationServices

struct MenuBarItemBounds: Identifiable {
    let id = UUID()
    let frame: CGRect
    let title: String
    let appOwner: String
}

class MenuBarScanner: ObservableObject {
    static let shared = MenuBarScanner()
    
    @Published var foundItems: [MenuBarItemBounds] = []
    
    private var timer: Timer?
    
    func startScanning() {
        // Scan every 2 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.scan()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func scan() {
        var newItems: [MenuBarItemBounds] = []
        
        // Scan ALL running applications for menu bar items
        let runningApps = NSWorkspace.shared.runningApplications
        
        for app in runningApps {
            // Skip apps without a bundle identifier
            guard let bundleID = app.bundleIdentifier else { continue }
            
            let pid = app.processIdentifier
            let axApp = AXUIElementCreateApplication(pid)
            
            // Get Children
            var childrenRef: CFTypeRef?
            let result = AXUIElementCopyAttributeValue(axApp, kAXChildrenAttribute as CFString, &childrenRef)
            
            if result == .success, let _ = childrenRef as? [AXUIElement] {
                // Traverse children looking for status items
                let items = traverse(element: axApp, depth: 0, appName: app.localizedName ?? bundleID)
                newItems.append(contentsOf: items)
            }
        }
        
        // Filter to only items in the menu bar area (Y position near top of screen)
        // Menu bar items typically have Y position < 50
        let menuBarItems = newItems.filter { $0.frame.origin.y < 50 }
        
        // Sort by X position (left to right)
        let sortedItems = menuBarItems.sorted { $0.frame.origin.x < $1.frame.origin.x }
        
        DispatchQueue.main.async {
            self.foundItems = sortedItems
            let appNames = sortedItems.map { $0.appOwner }
            print("Scanner: Found \(sortedItems.count) items: \(appNames)")
        }
    }
    
    private func traverse(element: AXUIElement, depth: Int, appName: String = "Unknown") -> [MenuBarItemBounds] {
        if depth > 2 { return [] } // Limit recursion performance
        
        var found: [MenuBarItemBounds] = []
        var childrenRef: CFTypeRef?
        _ = AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &childrenRef)
        
        guard let children = childrenRef as? [AXUIElement] else { return [] }
        
        for child in children {
            // Check if this is a wrapper for a status item
            // Usually valid items have a Frame and a Role
            var roleRef: CFTypeRef?
            _ = AXUIElementCopyAttributeValue(child, kAXRoleAttribute as CFString, &roleRef)
            
            // Get subrole for more specific identification
            var subroleRef: CFTypeRef?
            _ = AXUIElementCopyAttributeValue(child, kAXSubroleAttribute as CFString, &subroleRef)
            let subrole = subroleRef as? String ?? ""
            
            if let role = roleRef as? String {
                // AXMenuExtra = Status bar items (Wi-Fi, Battery, third-party icons)
                // AXMenuBarItem with no subrole and specific width = also status items
                // Regular app menus have different characteristics
                
                let isStatusItem = role == "AXMenuExtra" || 
                    (role == "AXMenuBarItem" && subrole == "AXMenuExtra")
                
                if isStatusItem {
                    if let frame = getFrame(element: child) {
                        found.append(MenuBarItemBounds(frame: frame, title: role, appOwner: appName))
                    }
                }
            }
            
            // Recurse
            found.append(contentsOf: traverse(element: child, depth: depth + 1, appName: appName))
        }
        
        return found
    }
    
    private func getFrame(element: AXUIElement) -> CGRect? {
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        
        AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &positionRef)
        AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &sizeRef)
        
        var position = CGPoint.zero
        var size = CGSize.zero
        
        // Swift 6 requires explicit CFTypeID comparison for CoreFoundation types
        if let positionRef = positionRef,
           CFGetTypeID(positionRef) == AXValueGetTypeID() {
            let posVal = positionRef as! AXValue
            AXValueGetValue(posVal, .cgPoint, &position)
        }
        if let sizeRef = sizeRef,
           CFGetTypeID(sizeRef) == AXValueGetTypeID() {
            let sizeVal = sizeRef as! AXValue
            AXValueGetValue(sizeVal, .cgSize, &size)
        }
        
        if size.width > 0 && size.height > 0 {
            return CGRect(origin: position, size: size)
        }
        return nil
    }
}
