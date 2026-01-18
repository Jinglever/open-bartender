import SwiftUI

struct PreferencesView: View {
    @ObservedObject var scanner = MenuBarScanner.shared
    @State private var animateStats = false
    
    var body: some View {
        ZStack {
            // Background Layer - thicker material for better readability
            Rectangle()
                .fill(Material.regularMaterial)
                .ignoresSafeArea()
            
            // Subtle gradient overlay
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "menubar.rectangle")
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .padding(10)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("OpenBartender")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                        Text("Menu Bar Manager")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Permission Status Badge
                    HStack(spacing: 6) {
                        Circle()
                            .fill(PermissionsManager.shared.isAccessibilityTrusted ? Color.green : Color.orange)
                            .frame(width: 8, height: 8)
                        Text(PermissionsManager.shared.isAccessibilityTrusted ? "Active" : "Permission Needed")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(PermissionsManager.shared.isAccessibilityTrusted ? .green : .orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Material.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.05), radius: 2)
                    )
                    .onTapGesture {
                        if !PermissionsManager.shared.isAccessibilityTrusted {
                            PermissionsManager.shared.promptForAccessibility()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Content Card
                VStack(spacing: 0) {
                    HStack {
                        Text("Detected Detected Items")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(scanner.foundItems.count)")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .scaleEffect(animateStats ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: animateStats)
                    }
                    .padding()
                    
                    Divider()
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(scanner.foundItems) { item in
                                HStack(spacing: 12) {
                                    // Simulated App Icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .fill(Color.white.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "app.fill")
                                            .foregroundColor(.secondary.opacity(0.5))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.appOwner)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                        HStack {
                                            Text("X: \(Int(item.frame.origin.x))")
                                            Text("•")
                                            Text("W: \(Int(item.frame.width))")
                                        }
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    
                                    // Visual representation of position
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: CGFloat(item.frame.width) / 2, height: 6)
                                }
                                .padding(10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.white.opacity(0.05))
                                )
                            }
                        }
                        .padding()
                    }
                    .frame(height: 250)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Material.thickMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Footer
                HStack {
                    Button(action: {
                        withAnimation {
                            animateStats = true
                        }
                        scanner.scan()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            animateStats = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Refresh Scan")
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("v0.1.0 • Early Alpha")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .padding()
            }
        }
        .frame(width: 420, height: 500)
    }
}
