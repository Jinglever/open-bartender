import SwiftUI

struct PreferencesView: View {
    @ObservedObject var scanner = MenuBarScanner.shared
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "menubar.rectangle")
                    .font(.title2)
                Text("Bartender Clone")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding()
            
            Divider()
            
            // Stats
            HStack {
                Text("Detected Menu Bar Items:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(scanner.foundItems.count)")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // List of items
            List(scanner.foundItems) { item in
                HStack {
                    Image(systemName: "app.dashed")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.appOwner)
                            .fontWeight(.medium)
                        Text("Position: X=\(Int(item.frame.origin.x)), Width=\(Int(item.frame.width))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 2)
            }
            .frame(minHeight: 200)
            
            Divider()
            
            // Footer
            HStack {
                Button("Refresh") {
                    scanner.scan()
                }
                
                Spacer()
                
                Text("Icon hidden? Too many menu bar items!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(width: 400, height: 380)
    }
}
