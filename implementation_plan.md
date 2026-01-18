# Implementation Plan - "Bartender" Native Clone

This plan outlines the steps to build a native macOS menu bar manager similar to Bartender/Hidden Bar.

## Core Architecture
This will be a **Swift** project using **AppKit** (backend logic) and **SwiftUI** (Preferences/UI).

### 1. The Strategy: "The Splitter Method"
Mimicking the robust behavior of open-source tools like *Hidden Bar* or *Dozer* is the most viable path without reverse-engineering private Apple frameworks.
1.  **The Splitter**: We create a native `NSStatusItem` (the vertical pipe `|`).
2.  **User Setup**: The user Command+Drags legitimate system icons to the *left* or *right* of our Splitter.
3.  **Hiding Mechanism**:
    *   We use the **Accessibility API** (`AXUIElement`) to scan the Menu Bar's UI hierarchy.
    *   We identify the position of our Splitter.
    *   We identify all items to the *left* of the splitter.
    *   **Action**: There is no public API to "hide" another app's item.
        *   *Approach A (Masking)*: We draw a window allowing clicks to pass through? No, looks bad.
        *   *Approach B (Native Collapse)*: This requires private APIs.
        *   *Approach C (The "Bartender" Way)*: We locate the icons, take a snapshot of them (requiring Screen Recording permission), display them in a **secondary bar** (our own window), and then mask the original area.

**Target for MVP**: We will build **Approach C (The Secondary Bar)** foundation.
1.  **Permissions Engine**: Request Accessibility & Screen Recording permissions.
2.  **Scanner**: A service that iterates current Menu Bar items.
3.  **Secondary Bar**: A floating `NSPanel` that can host "hidden" items.

## Step-by-Step Implementation

### Phase 1: Project Skeleton & Permissions
- Initialize a standard Swift Package Manager executable or standard App structure.
- create `MainApp.swift` (App lifecycle).
- create `PermissionsManager.swift` to handle:
    - `AXIsProcessTrusted()` (Accessibility)
    - `CGDisplayStream` check (Screen Recording)

### Phase 2: Menu Bar Scanner (The Hard Part)
- Create `MenuBarScanner.swift`.
- Use `CoreGraphics` to find the Menu Bar window.
- Use `AXUIElementCreateSystemWide` -> Find `AXMenuBar` -> List `AXChildren`.
- Extract frames (positions/sizes) of every status item.

### Phase 3: The "Bartender Bar" (UI)
- Create a floating, borderless `NSPanel` (SwiftUI View).
- This window will act as the "Secondary Shelf" where hidden items live.

### Phase 4: Preferences
- A Settings window to toggle aggressive hiding, auto-hide delay, etc.

## Limitations
- **Private APIs**: Truly Hiding (removing) items often requires private calls which are brittle. We will focus on *detecting* them first.
- **Sandboxing**: This app *cannot* be sandboxed if it wants to control other apps. It must be distributed outside the Mac App Store.

## Directory Structure
```text
BartenderClone/
├── Sources/
│   ├── App/
│   │   ├── BartenderCloneApp.swift
│   │   └── AppDelegate.swift
│   ├── Core/
│   │   ├── MenuBarScanner.swift     # Accessibility Logic
│   │   └── PermissionsManager.swift
│   └── UI/
│       ├── BartenderBarWindow.swift # The floating shelf
│       └── PreferencesView.swift
└── Package.swift
```
