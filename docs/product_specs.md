# Product Requirements Document (PRD) - OpenBartender

## ⚓ The Product Anchor
**Why OpenBartender?**
Bartender is a great utility, but it is closed-source, requires invasive permissions (Screen Recording/Accessibility), and has recently changed ownership, raising trust concerns. 

**OpenBartender** is the **transparent, trust-first alternative**.
*   **Open Source**: Verify exactly what we do with your Screen Recording permissions.
*   **Native & Lightweight**: Built with Swift/SwiftUI, using 0% CPU when idle.
*   **Privacy-Centric**: No analytics, no "cloud" features, no tracking. Just a utility.

## 👥 Target Audience
*   **Developers & Power Users**: People who have 20+ icons in their menu bar (Docker, iStats, VPNs, etc.) and crave organization.
*   **Privacy Advocates**: Users uncomfortable granting invasive permissions to closed-source apps.
*   **Minimalists**: Users who want a clean desktop aesthetic without losing functionality.

## 🎨 Design Philosophy
1.  **Invisible by Default**: The app should get out of the way. The menu bar should look stock until the user interacts with it.
2.  **Native Aesthetics**: The "Secondary Shelf" must look exactly like a control center module or native macOS UI component. No custom "skins" that look out of place. 
    *   *Keywords*: Glassmorphism, Blur, Rounded Corners, SF Symbols.
3.  **Fluid Interactions**: Opening the bar must be instant (0ms delay). Animations should use standard `spring` curves to feel physical.

## 🌟 Key Features & Behavior

### 1. The "Secondary Shelf" (The Hider)
Instead of just hiding icons, we move them to a localized, floating "Shelf".
*   **Behavior**:
    *   **Normal State**: Only "Always Visible" items (Clock, Wi-Fi) + OpenBartender Icon (`☰`) are shown.
    *   **Active State**: Clicking `☰` (or Hovering) reveals the "Shelf" just below the menu bar.
    *   **The Shelf**: A pill-shaped floating panel containing the "Hidden" items.
    *   **Auto-Hide**: Click anywhere else, or wait 3s, and the shelf fades out.

### 2. Smart Triggers (The Brain)
Items should appear *only when relevant*.
*   **Battery**: Hide battery icon normally. Show it automatically when < 20% or Charging.
*   **Wi-Fi**: Hide Wi-Fi icon normally. Show it if "Disconnected" or "Searching".
*   **VPN**: Show VPN icon only when Disconnected (security alert).
*   **Screen Recording**: Show icon only when active.

### 3. "The Notch" Awareness
*   **Problem**: on MacBook Pros, standard hiding doesn't work well because items get lost behind the notch.
*   **Solution**: The "Shelf" must position itself *below* the notch, ensuring all icons are accessible even if the physical menu bar is full.

### 4. Quick Search (Cmd+K)
*   A spotlight-like search bar to instantly find and **click** a menu bar item via keyboard.
    *   *User Story*: "I want to open Docker settings but I don't want to hunt for the icon. I hit Cmd+Option+Space, type 'doc', hit Enter, and the menu opens."

## 📱 User Experience (UX) Flow
1.  **Onboarding**: 
    - User grants Permissions.
    - App scans current items.
    - **Interactive Setup**: User drags items into two buckets: "Always Visible" vs "Hidden".
2.  **Daily Use**:
    - User sees a clean bar.
    - User hovers over the empty space -> The hidden items slide down.
    - User clicks an item -> The shelf stays open while the menu interacts.
3.  **Customization**:
    - Right-click the `☰` icon to enter "Layout Mode" where items wiggle (like iOS home screen) and can be dragged between shelves.

## 📈 Success Metrics
*   **Performance**: < 1% CPU usage at idle.
*   **Latency**: open/close animation starts < 16ms after click.
*   **Reliability**: Does not crash the system menu bar (a common issue with these utilities).

## 🛡 Security & Privacy
*   **Screen Recording Permission**: STRICTLY used only to capture the visual of the icon to render it in the secondary shelf. No data is ever saved to disk or transmitted.
*   **Accessibility Permission**: Used to determine location of clicks.

---

## ✅ Acceptance Criteria & Test Plan

These criteria define "Done" for each feature and serve as the basis for automated and manual testing.

### 1. Menu Bar Scanner (Core Engine)
*   **AC1.1**: Scanner MUST detect 100% of standard `NSStatusItem` icons (e.g., Wi-Fi, Clock, Spotlight).
*   **AC1.2**: Scanner MUST detect third-party apps (e.g., Docker, Notion, Weak Auras).
*   **AC1.3**: Scanner MUST correctly filter out non-status items (e.g., "File", "Edit" menus).
*   **AC1.4 (Performance)**: Scanning pass must complete in < 50ms (measured from `AXUIElement` traversal to data model update).
*   **AC1.5 (Reactive)**: Scanner must update the model within 2 seconds when a new app is launched or quit.

### 2. Secondary Shelf (UI/UX)
*   **AC2.1**: Clicking the OpenBartender icon (`☰`) MUST toggle the shelf visibility.
*   **AC2.2**: The shelf MUST appear visually *below* the menu bar, never overlapping system menus.
*   **AC2.3**: On Macs with a notch, the shelf MUST appear below the notch area.
*   **AC2.4**: Clicking outside the shelf MUST close it (focus loss behavior).
*   **AC2.5**: The shelf MUST support clicking on the items inside it (pass-through clicks to the actual app).

### 3. Smart Triggers (Logic)
*   **AC3.1 (Battery)**:
    *   *Given* Battery trigger is ON,
    *   *When* battery level > 20% AND not charging,
    *   *Then* Battery icon is HIDDEN.
    *   *When* battery level <= 20% OR charging,
    *   *Then* Battery icon is SHOWN.
*   **AC3.2 (Wi-Fi)**:
    *   *Given* Wi-Fi trigger is ON,
    *   *When* Wi-Fi is Connected,
    *   *Then* icon is HIDDEN.
    *   *When* Wi-Fi is Disconnected/Searching,
    *   *Then* icon is SHOWN.

### 4. Search & Interaction
*   **AC4.1**: Pressing the Hotkey (e.g., `Cmd+Opt+Space`) MUST open the Quick Search bar.
*   **AC4.2**: Typing "Wifi" and pressing Enter MUST simulate a click on the Wi-Fi icon.
*   **AC4.3**: Navigation via Arrow Keys in the search result list MUST be supported.

### 5. Performance Thresholds
*   **AC5.1**: CPU usage at idle (background mode) MUST be < 0.5%.
*   **AC5.2**: Memory footprint MUST be < 50MB.
*   **AC5.3**: No UI jank during open/close animations (min 60fps).

## 🧪 Testing Strategy
1.  **Unit Tests**:
    *   Verify `MenuBarScanner` parsing logic with mock `AXUIElement` data.
    *   Test `TriggerService` state machines (Battery/Network logic).
2.  **UI/Integration Tests**:
    *   Use `XCTest` to verify window existence and hierarchy.
    *   *Note*: Testing actual menu bar clicks requires Accessibility Permissions in CI/CD, which is complex. Manual "Smoke Tests" are required for click-through verification.
3.  **Manual Acceptance (The "Smoke Test")**:
    *   Launch App -> Check Icon Visible.
    *   Click Icon -> Check Shelf Visible.
    *   Open 5 apps -> Verify all 5 appear in scanner list.
    *   Quit App -> Verify menu bar returns to standard state (Safety Fallback).
