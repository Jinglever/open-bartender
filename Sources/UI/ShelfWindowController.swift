import AppKit
import SwiftUI

/// Controls the floating "Shelf" window that displays hidden menu bar items
class ShelfWindowController: NSObject {
    static let shared = ShelfWindowController()
    
    private var shelfPanel: NSPanel?
    private var isVisible = false
    private var clickMonitor: Any?
    private var keyMonitor: Any?
    
    private override init() {
        super.init()
    }
    
    // MARK: - Public API
    
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }
    
    func show() {
        if shelfPanel == nil {
            createShelfPanel()
        }
        
        positionShelf()
        
        shelfPanel?.alphaValue = 0
        shelfPanel?.orderFrontRegardless()
        
        // Fade in animation
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            shelfPanel?.animator().alphaValue = 1
        }
        
        isVisible = true
        
        // Add event monitors
        startEventMonitors()
    }
    
    func hide() {
        guard let panel = shelfPanel, isVisible else { return }
        
        // Stop event monitors
        stopEventMonitors()
        
        // Fade out animation
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.15
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: {
            panel.orderOut(nil)
        })
        
        isVisible = false
    }
    
    // MARK: - Event Monitors
    
    private func startEventMonitors() {
        // Monitor for clicks outside the shelf
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let panel = self.shelfPanel else { return }
            
            // Check if click is outside the shelf
            let clickLocation = event.locationInWindow
            let screenLocation = NSEvent.mouseLocation
            
            if !panel.frame.contains(screenLocation) {
                self.hide()
            }
        }
        
        // Monitor for Escape key (global because our panel is non-activating)
        keyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // Escape key
                self?.hide()
            }
        }
    }
    
    private func stopEventMonitors() {
        if let monitor = clickMonitor {
            NSEvent.removeMonitor(monitor)
            clickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
    
    // MARK: - Private Methods
    
    private func createShelfPanel() {
        // Create SwiftUI content
        let contentView = ShelfView()
        let hostingView = NSHostingView(rootView: contentView)
        
        // Calculate initial size - wider and taller for better icon display
        let shelfWidth: CGFloat = 400
        let shelfHeight: CGFloat = 70
        
        // Create borderless panel
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: shelfWidth, height: shelfHeight),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        // Panel configuration
        panel.level = .popUpMenu  // Above menu bar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Add visual effect background for blur
        let visualEffect = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: shelfWidth, height: shelfHeight))
        visualEffect.material = .hudWindow
        visualEffect.state = .active
        visualEffect.blendingMode = .behindWindow
        visualEffect.wantsLayer = true
        visualEffect.layer?.cornerRadius = 12
        visualEffect.layer?.masksToBounds = true
        
        // Add shadow to the visual effect layer
        visualEffect.shadow = NSShadow()
        visualEffect.shadow?.shadowColor = NSColor.black.withAlphaComponent(0.3)
        visualEffect.shadow?.shadowOffset = NSSize(width: 0, height: -3)
        visualEffect.shadow?.shadowBlurRadius = 10
        
        // Build view hierarchy
        visualEffect.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor)
        ])
        
        panel.contentView = visualEffect
        
        self.shelfPanel = panel
    }
    
    private func positionShelf() {
        guard let panel = shelfPanel, let screen = NSScreen.main else { return }
        
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        
        // Calculate menu bar height (difference between full screen and visible)
        let menuBarHeight = screenFrame.height - visibleFrame.height - visibleFrame.origin.y
        
        // Check for notch (safeAreaInsets available in macOS 12+)
        var notchOffset: CGFloat = 0
        if #available(macOS 12.0, *) {
            if let safeInsets = screen.safeAreaInsets, safeInsets.top > 0 {
                // Has a notch - add extra offset
                notchOffset = 8
            }
        }
        
        // Position below menu bar, right-aligned
        let shelfWidth = panel.frame.width
        let padding: CGFloat = 8
        
        let xPosition = screenFrame.width - shelfWidth - padding
        let yPosition = screenFrame.height - menuBarHeight - panel.frame.height - padding - notchOffset
        
        panel.setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
    }
}

// MARK: - NSScreen Extension for Safe Area

@available(macOS 12.0, *)
extension NSScreen {
    var safeAreaInsets: NSEdgeInsets? {
        // Use the auxiliaryTopLeftArea and auxiliaryTopRightArea to detect notch
        // If these exist, there's a notch
        if self.auxiliaryTopLeftArea != nil || self.auxiliaryTopRightArea != nil {
            return NSEdgeInsets(top: 38, left: 0, bottom: 0, right: 0) // Approximate notch height
        }
        return nil
    }
}
