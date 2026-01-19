# Implementation Checklist - OpenBartender

A step-by-step guide to building OpenBartender. Check off each task as completed.

---

## Phase 1: Foundation ✅ (Completed)

### 1.1 Project Setup
- [x] Initialize Swift Package Manager project
- [x] Configure `Package.swift` with macOS 13+ target
- [x] Create directory structure (`Sources/App`, `Sources/Core`, `Sources/UI`)
- [x] Create `Info.plist` with `LSUIElement = true` (agent app)
- [x] Create `build_app.sh` script for .app bundle creation
- [x] Initialize Git repository
- [x] Push to GitHub (`open-bartender`)

### 1.2 Permissions System
- [x] Create `PermissionsManager.swift`
- [x] Implement `AXIsProcessTrusted()` check
- [x] Implement `AXIsProcessTrustedWithOptions()` for prompting
- [ ] Add Screen Recording permission check (`CGPreflightScreenCaptureAccess`)
- [ ] Add Screen Recording permission prompt (`CGRequestScreenCaptureAccess`)

### 1.3 Menu Bar Scanner (Basic)
- [x] Create `MenuBarScanner.swift`
- [x] Implement `AXUIElementCreateApplication` traversal
- [x] Filter for `AXMenuExtra` role (status items only)
- [x] Extract frame coordinates (`kAXPositionAttribute`, `kAXSizeAttribute`)
- [x] Publish results via `@Published var foundItems`
- [x] Add periodic scanning timer (every 2 seconds)
- [ ] Optimize: Subscribe to `NSWorkspace.didLaunchApplicationNotification`
- [ ] Optimize: Add debouncing (500ms minimum interval)
- [ ] Optimize: Move scanning to background thread

### 1.4 Basic UI
- [x] Create `NSStatusItem` with icon (`☰ OB`)
- [x] Create basic `PreferencesView.swift`
- [x] Implement floating window (stays on top)
- [x] Apply premium styling (Glassmorphism, SF Rounded fonts)
- [x] Display detected items in scrollable list
- [x] Add permission status indicator (green/orange dot)

---

## Phase 2: The Secondary Shelf (The Bar) ✅

### 2.1 Shelf Window Infrastructure
- [x] Create `ShelfWindowController.swift`
- [x] Create borderless `NSPanel` with `.nonactivatingPanel` style
- [x] Set window level to `.popUpMenu` (above menu bar)
- [x] Implement `NSVisualEffectView` background (blur)
- [x] Add rounded corners (16pt radius)
- [x] Add subtle shadow

### 2.2 Shelf Positioning
- [x] Detect menu bar height via `NSScreen.visibleFrame`
- [x] Detect notch presence via `safeAreaInsets.top`
- [x] Calculate shelf Y position (below notch if present)
- [x] Position shelf horizontally (right-aligned with menu bar icons)
- [ ] Handle multi-monitor scenarios

### 2.3 Shelf Content View
- [x] Create `ShelfView.swift` (SwiftUI)
- [x] Display horizontal list of "hidden" items
- [x] Show item icons (placeholder images initially)
- [x] Add hover highlight effect
- [x] Add smooth fade-in/fade-out animation

### 2.4 Toggle Logic
- [x] Click status bar icon → Toggle shelf visibility
- [x] Click outside shelf → Close shelf
- [x] Escape key → Close shelf
- [ ] Hover mode (optional): Show on hover, hide on leave

---

## Phase 3: Icon Capture & Display ✅

### 3.1 Screen Capture Setup
- [x] Request Screen Recording permission on first use
- [x] Create `IconCaptureService.swift`
- [x] Implement `CGWindowListCreateImage` for specific rect
- [x] Capture icon at coordinates from Scanner
- [x] Convert `CGImage` to SwiftUI `Image`

### 3.2 Live Icon Display
- [x] Replace placeholder icons with captured images
- [x] Cache captured images (avoid re-capture every frame)
- [ ] Invalidate cache when Scanner detects position change
- [x] Handle failed captures gracefully (show placeholder)

### 3.3 Click Pass-Through
- [x] Create `ClickSimulator.swift`
- [x] Implement `CGEvent` mouse click generation
- [x] On shelf item click: Hide shelf temporarily
- [x] Simulate click at original icon coordinates
- [x] Restore shelf after delay (100ms)

---

## Phase 4: The Masking System (Hiding)

### 4.1 Mask Window
- [ ] Create `MaskWindowController.swift`
- [ ] Create borderless `NSWindow` at `.statusBar + 1` level
- [ ] Position over "hidden" icon coordinates
- [ ] Match menu bar background appearance

### 4.2 Background Matching
- [ ] Option A: Solid color (detect menu bar color mode: Dark/Light)
- [ ] Option B: Capture wallpaper behind menu bar region
- [ ] Apply captured/color to mask window background

### 4.3 Mask Interaction
- [ ] Click on mask → Show shelf (toggle behavior)
- [ ] Right-click on mask → Show context menu
- [ ] Update mask position when Scanner detects changes

---

## Phase 5: Configuration & Persistence

### 5.1 User Preferences
- [ ] Create `SettingsManager.swift`
- [ ] Store preferences in `UserDefaults`:
  - [ ] `alwaysVisibleItems: [String]` (bundle IDs)
  - [ ] `hiddenItems: [String]` (bundle IDs)
  - [ ] `autoHideDelay: Double` (seconds)
  - [ ] `showOnHover: Bool`
- [ ] Create settings UI in Preferences window

### 5.2 Item Configuration UI
- [ ] Add toggle switch per item: "Always Visible" / "Hidden"
- [ ] Persist selection immediately
- [ ] Reload configuration on app launch

### 5.3 Layout Persistence
- [ ] Save item order to JSON file
- [ ] Store in `~/Library/Application Support/OpenBartender/`
- [ ] Load on startup
- [ ] Export/Import configuration (future)

---

## Phase 6: Smart Triggers

### 6.1 Battery Trigger
- [ ] Create `BatteryMonitor.swift`
- [ ] Use `IOKit` (`IOPowerSources`) to read battery state
- [ ] Detect charging status
- [ ] Detect battery percentage
- [ ] Emit visibility change when threshold crossed (<20%)

### 6.2 Network Trigger
- [ ] Create `NetworkMonitor.swift`
- [ ] Use `NWPathMonitor` from `Network.framework`
- [ ] Detect Wi-Fi connected/disconnected
- [ ] Emit visibility change on disconnect

### 6.3 Trigger UI
- [ ] Add Triggers section in Preferences
- [ ] Toggle: "Show Battery when low"
- [ ] Toggle: "Show Wi-Fi when disconnected"
- [ ] Bind toggles to monitor activation

---

## Phase 7: Global Hotkey

### 7.1 Hotkey Capture
- [ ] Create `HotkeyManager.swift`
- [ ] Use `NSEvent.addGlobalMonitorForEvents(matching: .keyDown)`
- [ ] Default hotkey: `Cmd+Opt+Space`
- [ ] Toggle shelf on hotkey press

### 7.2 Hotkey Configuration
- [ ] Add "Change Hotkey" button in Preferences
- [ ] Create hotkey recorder view (capture next key combo)
- [ ] Save custom hotkey to UserDefaults
- [ ] Validate no conflict with system shortcuts

---

## Phase 8: Quick Search

### 8.1 Search UI
- [ ] Create `SearchWindowController.swift`
- [ ] Floating, centered window (Spotlight-style)
- [ ] Text field with large placeholder: "Search menu bar items..."
- [ ] Results list below

### 8.2 Search Logic
- [ ] Filter `foundItems` by fuzzy matching on `appOwner`
- [ ] Highlight matching characters
- [ ] Arrow key navigation
- [ ] Enter → Click selected item (via ClickSimulator)

### 8.3 Hotkey Integration
- [ ] Bind `Cmd+Opt+K` (or user-configured) to open Search
- [ ] Escape → Close Search

---

## Phase 9: Polish & Release

### 9.1 Performance Optimization
- [ ] Profile with Instruments (CPU, Memory)
- [ ] Verify <0.5% CPU at idle
- [ ] Verify <50MB memory
- [ ] Fix any animation jank (target 60fps)

### 9.2 Error Handling
- [ ] Handle permission denied gracefully
- [ ] Handle Scanner failures (retry with backoff)
- [ ] Add crash reporting (optional, opt-in)

### 9.3 Documentation
- [ ] Update README with installation instructions
- [ ] Add screenshots/GIFs to README
- [ ] Create CHANGELOG.md
- [ ] Add LICENSE (MIT or similar)

### 9.4 Distribution
- [ ] Create signed .app bundle
- [ ] Notarize with Apple
- [ ] Create GitHub Release
- [ ] (Optional) Submit to Homebrew Cask

---

## Progress Summary

| Phase | Status | Completion |
|-------|--------|------------|
| Phase 1: Foundation | ✅ Complete | 85% |
| Phase 2: Shelf | ⏳ Not Started | 0% |
| Phase 3: Icon Capture | ⏳ Not Started | 0% |
| Phase 4: Masking | ⏳ Not Started | 0% |
| Phase 5: Config | ⏳ Not Started | 0% |
| Phase 6: Triggers | ⏳ Not Started | 0% |
| Phase 7: Hotkey | ⏳ Not Started | 0% |
| Phase 8: Search | ⏳ Not Started | 0% |
| Phase 9: Polish | ⏳ Not Started | 0% |

**Overall: ~10% Complete**

---
*Last Updated: Jan 19, 2026*
