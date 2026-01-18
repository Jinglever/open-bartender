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
*Drafted: Jan 19, 2026*
