# Technical Design Document - OpenBartender

## 1. High-Level Architecture
OpenBartender follows a **Modular MVVM** architecture. The app runs as an agent (`LSUIElement`) with no main window, orchestrating distinct background services that communicate via a central event bus (or Combine publishers).

```mermaid
graph TD
    APP[OpenBartender App] --> COR[Core Services]
    APP --> UI[UI Layer]
    
    subgraph Core Services
        SCn[Scanner Service] --> |AXUIElement| SYS[macOS System]
        TRG[Trigger Service] --> |IOKit/Network| SYS
        PMS[Permission Manager]
    end
    
    subgraph UI Layer
        STS[Status Bar Item]
        SHF[Shelf Window (Secondary Bar)]
        MSK[Mask Window (The Hider)]
        PREF[Preferences Window]
    end
    
    SCn --> |Update Items| SHF
    SCn --> |Target Frames| MSK
    TRG --> |Visibility States| SHF
```

## 2. Detailed Technical Solutions

### 2.1 The Scanner Engine (The "Eyes")
*   **Problem**: Reading menu bar items requires traversing a complex, undocumented UI hierarchy. Frequent scanning spikes CPU.
*   **Solution**: **Event-Driven + Debounced Polling**.
    *   **Primary trigger**: Subscribe to `NSWorkspace.didLaunchApplicationNotification` and `didTerminateApplicationNotification`. Scan immediately on these events.
    *   **Secondary trigger**: A low-frequency timer (e.g., every 5s) to catch "zombie" icons or shifting positions.
    *   **Debounce**: Enforce a minimum interval (e.g., 500ms) between scans to prevent storms.
    *   **API**: Use `AXUIElementCreateApplication` -> `AXUIElementCopyAttributeValue` for `kAXChildrenAttribute`.
    *   **Optimization**: Cache `AXUIElement` references. Don't re-create them every scan; only validity-check them.

### 2.2 The "Hiding" Mechanism (The "Mask")
*   **Problem**: macOS does not allow third-party apps to programmatically *remove* or *reorder* other apps' status items from the system bar.
*   **Solution**: **The Visual Masking Strategy**.
    *   We cannot "remove" items. We **cover** them.
    *   **Implementation**:
        1.  Create an `NSWindow` with `level = .statusBar + 1`.
        2.  Position it exactly over the "Hidden" items' coordinates (detected by Scanner).
        3.  **Background Matching**:
            *   *Easiest*: Solid color (if user uses solid bar).
            *   *Advanced*: taking a screenshot of the desktop wallpaper *behind* the menu bar and applying it to our Mask Window. This creates a "Transparent" illusion even if we are actually an opaque window blocking the icons.
    *   **Interaction**: The mask window captures clicks. If a user clicks a "hidden" area, we can either do nothing (effectively disabling the icon) or interpret it as a "Show Shelf" trigger.

### 2.3 The Secondary Shelf (The "Clone")
*   **Problem**: Detailed above, we can mask the original items, but how do we show them in the secondary bar? We can't "move" the original UI element.
*   **Solution**: **Live Replicas via Screen Capture**.
    *   **Technique**: Use `CGWindowListCreateImage` to capture the *exact pixels* of the original status item (using the Frame from Scanner).
    *   **Rendering**: Display this captured `CGImage` in our Secondary Shelf.
    *   **Interaction (The Trick)**:
        *   When user clicks the *Replica* in the Shelf:
        *   We calculate the screen coordinates of the *Original* (hidden) item.
        *   We employ `CGEvent` (Quartz Event Services) to simulate a hardware mouse click at those coordinates.
        *   This opens the original menu (which appears at the original location).
    *   **Visual Polish**: The Secondary Bar itself is a standard SwiftUI View with `VisualEffectBlur` background.

### 2.4 Smart Triggers (The "Brain")
*   **Battery**:
    *   **API**: `IOKit` framework (`IOPowerSources`).
    *   **Logic**: Poll every 60s. If `% < 20` or `isCharging == true`, emit `show(BatteryID)`.
*   **Wi-Fi**:
    *   **API**: `CoreWLAN` or `Network.framework` (`NWPathMonitor`).
    *   **Logic**: Monitor connection changes. If `status != .satisfied`, emit `show(WiFiID)`.
*   **Screen Recording**:
    *   **API**: `CGWindowListCopyWindowInfo` checking for distinct overlay windows or `tccutil` checks (harder due to sandbox). 
    *   *Alternative*: Check for the "orange dot" system indicator process (unreliable).
    *   *Fallback*: User manual toggle for "Recording Mode".

## 3. Data Persistence strategy
*   **Configuration**: `UserDefaults`.
    *   `ShowBatteryPercentage`: Bool
    *   `ShelfPosition`: Top/Bottom
*   **Layout State**: `JSON` (stored in `Application Support`).
    *   Structure:
        ```json
        {
          "alwaysVisible": ["com.apple.clock", "com.apple.controlcenter"],
          "hidden": ["com.docker.docker", "com.tailscale.ipn"],
          "alwaysHidden": ["com.adobe.creative-cloud"]
        }
        ```
    *   This allows syncing configs via dotfiles (future feature).

## 4. Performance Constraints & Safety
*   **CPU Budget**: The Scanner is the heaviest component.
    *   *Constraint*: Parsing the UI hierarchy involves IPC calls to the Window Server (expensive).
    *   *Mitigation*: Never scan on main thread. Use `DispatchQueue.global(qos: .utility)`.
*   **Memory Safety**:
    *   `CGImage` caches can grow large. We must aggressively release captured icon images when the Shelf closes.

## 5. Security Model
*   **Trusted Executive**: We are an `AXTrusted` process.
*   **Input Simulation**: We generate input events (`CGEventPost`). This requires the same Accessibility permission we already have.
*   **Network**: Zero network access required for core function.

## 6. Global Hotkey Implementation
*   **Problem**: Capture keyboard shortcuts even when our app is not focused.
*   **Solution**: Use `NSEvent.addGlobalMonitorForEvents(matching: .keyDown)`.
    *   This works for Accessibility-trusted apps.
    *   Monitor for specific key combos (e.g., `Cmd+Opt+Space`).
    *   *Alternative*: `CGEventTap` for lower-level capture (more reliable but more complex).
*   **Registration**: Store user-configurable hotkey in `UserDefaults`. Default: `Cmd+Opt+Space`.

## 7. Notch & Menu Bar Positioning
*   **Menu Bar Height Detection**:
    *   `let menuBarHeight = NSApp.mainMenu?.menuBarHeight ?? 24`
    *   Or: `NSScreen.main!.frame.height - NSScreen.main!.visibleFrame.height - NSScreen.main!.visibleFrame.origin.y`
*   **Notch Detection**:
    *   Check `NSScreen.main?.safeAreaInsets` (macOS 12+).
    *   If `safeAreaInsets.top > 0`, a notch is present.
    *   **Notch Width**: Approximately 200px centered. Our Shelf should avoid this zone or position entirely below it.
*   **Shelf Positioning Formula**:
    *   `shelfY = screenHeight - menuBarHeight - shelfHeight - 4` (4px gap for visual separation).
    *   If notch present: `shelfY = screenHeight - menuBarHeight - notchHeight - shelfHeight`.

## 8. Click Pass-Through Sequence (Detailed)
When user clicks on a replica icon in the Secondary Shelf:
1.  **Hide Mask Window**: Temporarily set `maskWindow.orderOut(nil)` to reveal the original icon.
2.  **Hide Shelf Window**: `shelfWindow.orderOut(nil)` so it doesn't block.
3.  **Simulate Click**:
    *   Calculate original icon's center point from Scanner data.
    *   Create `CGEvent` for mouse-down and mouse-up at that point.
    *   Post events via `CGEventPost(.cghidEventTap, event)`.
4.  **Wait for Menu**: The original app's menu will appear at the icon's location.
5.  **Restore UI**: After a short delay (e.g., 100ms) or on next mouse-down outside the menu, bring Mask and Shelf windows back.

---
*Status: Design Complete - Ready for Implementation*
