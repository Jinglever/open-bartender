import AppKit
import CoreGraphics

/// Service to simulate mouse clicks at specific screen coordinates
class ClickSimulator {
    static let shared = ClickSimulator()
    
    private init() {}
    
    /// Simulates a mouse click at the center of the given frame
    /// - Parameters:
    ///   - frame: The CGRect of the target area in screen coordinates
    ///   - completion: Called after the click is performed
    func click(at frame: CGRect, completion: (() -> Void)? = nil) {
        // Calculate the center point of the icon
        let centerX = frame.origin.x + (frame.width / 2)
        let centerY = frame.origin.y + (frame.height / 2)
        let clickPoint = CGPoint(x: centerX, y: centerY)
        
        print("ClickSimulator: Clicking at \(clickPoint)")
        
        // Perform click on main thread after a tiny delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.performClick(at: clickPoint)
            completion?()
        }
    }
    
    /// Performs the actual mouse click using CGEvent
    private func performClick(at point: CGPoint) {
        // Create mouse down event
        guard let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: point,
            mouseButton: .left
        ) else {
            print("ClickSimulator: Failed to create mouseDown event")
            return
        }
        
        // Create mouse up event
        guard let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: point,
            mouseButton: .left
        ) else {
            print("ClickSimulator: Failed to create mouseUp event")
            return
        }
        
        // Post the events to the system
        mouseDown.post(tap: .cghidEventTap)
        
        // Small delay between down and up for reliability
        usleep(50000) // 50ms
        
        mouseUp.post(tap: .cghidEventTap)
        
        print("ClickSimulator: Click completed at \(point)")
    }
    
    /// Simulates a right-click at the center of the given frame
    func rightClick(at frame: CGRect, completion: (() -> Void)? = nil) {
        let centerX = frame.origin.x + (frame.width / 2)
        let centerY = frame.origin.y + (frame.height / 2)
        let clickPoint = CGPoint(x: centerX, y: centerY)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.performRightClick(at: clickPoint)
            completion?()
        }
    }
    
    private func performRightClick(at point: CGPoint) {
        guard let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: .rightMouseDown,
            mouseCursorPosition: point,
            mouseButton: .right
        ),
        let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: .rightMouseUp,
            mouseCursorPosition: point,
            mouseButton: .right
        ) else {
            print("ClickSimulator: Failed to create right-click events")
            return
        }
        
        mouseDown.post(tap: .cghidEventTap)
        usleep(50000)
        mouseUp.post(tap: .cghidEventTap)
    }
}
