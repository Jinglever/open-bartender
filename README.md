# Bartender Clone (Native)

A native macOS application skeleton that mimics the functionality of Bartender.

## How to Build and Run

1. **Build the project**:
   ```bash
   swift build
   ```

2. **Run the project**:
   ```bash
   swift run
   ```

## Accessibility Permissions
This app requires **Accessibility Permissions** (`AXIsProcessTrusted`) to read the position of menu bar items.
When you run it, if you see "Accessibility not trusted", you must:
1. Open **System Settings** -> **Privacy & Security** -> **Accessibility**.
2. Add your Terminal (e.g., iTerm or Terminal.app) if running via CLI, or the compiled `BartenderClone` binary.
3. Restart the app.

## Project Structure
- `Sources/App`: Main entry point (`BartenderCloneApp`) and `AppDelegate`.
- `Sources/Core`: Logic for `PermissionsManager` and `MenuBarScanner` (Accessibility API).
- `Sources/UI`: SwiftUI views (`PreferencesView`).
