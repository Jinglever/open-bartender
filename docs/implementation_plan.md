# Implementation Plan - OpenBartender

A native macOS menu bar manager to completely replace the official Bartender app.
**Goal**: Replicate Bartender 6 functionality using public APIs where possible, focusing on a premium, modern SwiftUI interface.

## 🎯 Core Features & Roadmap

### Phase 1: Foundation (Current Status: ✅)
- [x] **Project Skeleton:** Swift Package Manager + AppKit/SwiftUI hybrid.
- [x] **Permissions:** Accessibility (AX) permission handling.
- [x] **Scanner Engine:**
    - Detects status bar items from *all* running apps.
    - Filters legitimate status items (ignoring app menus).
    - Tracks position (X/Y) and dimensions.
- [x] **Basic UI:** Floating debug window (Preferences) + Status Bar Icon.
- [x] **Git Setup:** Repository initialized and pushed to GitHub.

### Phase 2: The "Bartender Bar" (Floating Shelf)
The signature feature: a secondary bar to hold "hidden" items.
- [ ] **Floating Panel:** Convert debug window to a transparent, pill-shaped `NSPanel`.
- [ ] **Positioning:** Automatically anchor the panel below the menu bar notch area.
- [ ] **Styling:** Implement Glassmorphism (`NSVisualEffectView`) and rounded corners.
- [ ] **Animations:** Smooth slide-in/slide-out transitions.

### Phase 3: Interaction & Hiding Logic
- [ ] **"Hiding" Implementation:**
    - *Strategy A (Visual)*: Draw a matching background window over "hidden" items in the main bar.
    - *Strategy B (Replication)*: Display clones of the icons in our Secondary Bar (using Screen Capture or Accessibility snapshots).
- [ ] **Toggle Logic:** Click main icon -> Show Secondary Bar.
- [ ] **Global Hotkey:** `Cmd+Option+Space` (or similar) to toggle the bar.

### Phase 4: Advanced Features (Bartender 6 Parity)
- [ ] **Triggers:**
    - Battery Monitor (show when specific % or charging).
    - Network Monitor (Wi-Fi status).
- [ ] **Styling Options:**
    - Custom colors/gradients for the bar.
    - Border width and color settings.
    - Shadow and corner radius adjustments.
- [ ] **Search:** "Quick Search" UI to type and filter visible apps.
- [ ] **Spacers:** Insert custom empty spaces or text/emoji separators.

## 🏗 Technical Architecture

### 1. MenuBarScanner (Core)
- **Responsibility:** Continuously reads `AXUIElement` hierarchy of `com.apple.controlcenter` and `com.apple.systemuiserver`.
- **Output:** A stream of `MenuBarItem` models with live frames (CGRect).
- **Optimization:** Debounce scanning to prevent high CPU usage.

### 2. OverlayWindow (The Bar)
- **Type:** `NSPanel` with `styleMask = [.borderless, .nonactivatingPanel]`.
- **Level:** `.floating` (above normal windows) or `.popUpMenu` (extremely high).
- **View:** SwiftUI `hostingController` with visual effect background.

### 3. MaskingService (The Hider)
- **Challenge:** macOS doesn't let us programmatically *remove* third-party icons.
- **Solution:** We will likely use a "Mask Window" roughly the color of the menu bar to visually obscure items, while reproducing them in our floating bar.

## 📦 Directory Structure
```text
OpenBartender/
├── Sources/
│   ├── App/
│   │   ├── OpenBartenderApp.swift  # Entry & Status Item
│   │   └── AppDelegate.swift
│   ├── Core/
│   │   ├── MenuBarScanner.swift    # AX Logic
│   │   ├── PermissionsManager.swift
│   │   └── HotkeyManager.swift     # Global Shortcuts (TODO)
│   ├── UI/
│   │   ├── BartenderBarView.swift  # The floating shelf (TODO)
│   │   └── SettingsView.swift      # Preferences
│   └── Services/
│       └── TriggerService.swift    # Battery/Network logic (TODO)
└── Package.swift
```

## ⚠️ Key Challenges
1.  **Notch Handling:** On MacBook Air/Pro, we must respect the notch area.
2.  **Private APIs:** We avoid private APIs to ensure stability, meaning we rely on Accessibility hacks rather than true system injection.
3.  **Permissions:** Requires Accessibility + potentially Screen Recording (for icon snapshots).

## 🔗 Resources
- **Repo:** [github.com/Jinglever/open-bartender](https://github.com/Jinglever/open-bartender)
- **Inspiration:** [Bartender 6](https://www.macbartender.com/)
