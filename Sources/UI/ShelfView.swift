import SwiftUI

/// The SwiftUI content view displayed inside the Shelf panel
struct ShelfView: View {
    @ObservedObject var scanner = MenuBarScanner.shared
    @State private var hoveredItem: UUID?
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(scanner.foundItems.prefix(10)) { item in
                ShelfItemView(item: item, isHovered: hoveredItem == item.id)
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.15)) {
                            hoveredItem = hovering ? item.id : nil
                        }
                    }
                    .onTapGesture {
                        handleItemClick(item)
                    }
            }
            
            if scanner.foundItems.isEmpty {
                Text("No items")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
    
    private func handleItemClick(_ item: MenuBarItemBounds) {
        print("Shelf: Clicked on \(item.appOwner) at \(item.frame)")
        
        // 1. Hide the shelf first so it doesn't block the click
        ShelfWindowController.shared.hide()
        
        // 2. Wait a moment for the shelf to disappear, then simulate click
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            ClickSimulator.shared.click(at: item.frame) {
                print("Shelf: Click pass-through completed for \(item.appOwner)")
            }
        }
    }
}

/// Individual item in the shelf
struct ShelfItemView: View {
    let item: MenuBarItemBounds
    let isHovered: Bool
    
    @State private var capturedImage: NSImage?
    
    var body: some View {
        VStack(spacing: 4) {
            // Icon display
            ZStack {
                // Hover background
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.15) : Color.clear)
                    .frame(width: 32, height: 32)
                
                if let nsImage = capturedImage {
                    // Show captured icon - use interpolation for better quality
                    Image(nsImage: nsImage)
                        .interpolation(.high)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 28, maxHeight: 24)
                } else {
                    // Fallback placeholder
                    Image(systemName: "app.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.primary.opacity(0.4))
                }
            }
            .scaleEffect(isHovered ? 1.08 : 1.0)
            
            // App name (truncated)
            Text(shortName(item.appOwner))
                .font(.system(size: 9, design: .rounded))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 40)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isHovered ? Color.white.opacity(0.1) : Color.clear)
        )
        .onAppear {
            captureIcon()
        }
    }
    
    private func captureIcon() {
        print("ShelfItemView: Attempting to capture icon for \(item.appOwner)")
        // Capture on background thread to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            let image = IconCaptureService.shared.captureIcon(at: item.frame, forApp: item.appOwner)
            DispatchQueue.main.async {
                if image != nil {
                    print("ShelfItemView: Got image for \(item.appOwner)")
                } else {
                    print("ShelfItemView: No image returned for \(item.appOwner)")
                }
                self.capturedImage = image
            }
        }
    }
    
    /// Shortens app name for display
    private func shortName(_ name: String) -> String {
        // Remove common suffixes
        let cleaned = name
            .replacingOccurrences(of: " Helper", with: "")
            .replacingOccurrences(of: " mini", with: "")
            .replacingOccurrences(of: "控制中心", with: "控制")
        
        // Truncate if too long
        if cleaned.count > 6 {
            return String(cleaned.prefix(5)) + "…"
        }
        return cleaned
    }
}
