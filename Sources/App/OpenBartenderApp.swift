import SwiftUI
import AppKit

@main
struct OpenBartenderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // We use Settings scene for macOS apps, but our main UI is the status item
        Settings {
            PreferencesView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var preferencesWindow: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("OpenBartender Started")
        
        // 1. Create Status Bar Item (more reliable than MenuBarExtra)
        setupStatusItem()
        
        // 2. Check Permissions
        let permissions = PermissionsManager.shared
        if !permissions.isAccessibilityTrusted {
            print("Accessibility not trusted. prompting...")
            permissions.promptForAccessibility()
        }
        
        // 3. Start the Scanner
        MenuBarScanner.shared.startScanning()
        
        // 4. Auto-open preferences on launch (helpful when menu bar icon is hidden by notch)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.openPreferences()
        }
    }
    
    private func setupStatusItem() {
        // Create a status item with fixed length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set autosave name so macOS remembers position after user drags it
        statusItem?.autosaveName = "com.jinglever.OpenBartender.statusItem"
        
        if let button = statusItem?.button {
            // Use text title which is more visible
            button.title = "☰ OB"
        }
        
        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func openPreferences() {
        if preferencesWindow == nil {
            let view = PreferencesView()
            preferencesWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 420, height: 500),
                styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                backing: .buffered, defer: false)
            preferencesWindow?.center()
            preferencesWindow?.title = "OpenBartender Preferences"
            preferencesWindow?.titlebarAppearsTransparent = true
            preferencesWindow?.isMovableByWindowBackground = true
            preferencesWindow?.backgroundColor = .clear // Important for transparency
            preferencesWindow?.contentView = NSHostingView(rootView: view)
            preferencesWindow?.isReleasedWhenClosed = false
            // Make window float on top so it doesn't disappear
            preferencesWindow?.level = .floating
            preferencesWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
        preferencesWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
