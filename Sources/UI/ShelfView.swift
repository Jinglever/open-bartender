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
        // TODO: Implement click pass-through (Phase 3)
        // For now, just log and hide the shelf
        print("Shelf: Clicked on \(item.appOwner)")
        ShelfWindowController.shared.hide()
    }
}

/// Individual item in the shelf
struct ShelfItemView: View {
    let item: MenuBarItemBounds
    let isHovered: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            // Placeholder icon (will be replaced with captured image in Phase 3)
            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(isHovered ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                    .frame(width: 28, height: 28)
                
                Image(systemName: "app.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.primary.opacity(0.6))
            }
            .scaleEffect(isHovered ? 1.1 : 1.0)
            
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
