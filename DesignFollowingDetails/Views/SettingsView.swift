import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // User Profile Section
                Section {
                    HStack(spacing: 15) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(userManager.currentUser?.name.prefix(2).uppercased() ?? "U")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(userManager.currentUser?.name ?? "Unknown User")
                                .font(.headline)
                            
                            Text(userManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(userManager.currentUser?.role.rawValue ?? "")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                
                // Permissions Section
                Section("Permissions") {
                    PermissionRow(
                        title: "Edit All Events",
                        isEnabled: userManager.currentUser?.permissions.canEditAllEvents ?? false
                    )
                    
                    PermissionRow(
                        title: "Approve Changes",
                        isEnabled: userManager.currentUser?.permissions.canApproveChanges ?? false
                    )
                    
                    PermissionRow(
                        title: "Manage Users",
                        isEnabled: userManager.currentUser?.permissions.canManageUsers ?? false
                    )
                    
                    PermissionRow(
                        title: "View Reports",
                        isEnabled: userManager.currentUser?.permissions.canViewReports ?? false
                    )
                    
                    if let threshold = userManager.currentUser?.permissions.approvalThreshold {
                        HStack {
                            Text("Approval Threshold")
                            Spacer()
                            Text("$\(threshold, specifier: "%.0f")")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // App Settings Section
                Section("App Settings") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.blue)
                        Text("Notifications")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                    
                    HStack {
                        Image(systemName: "moon")
                            .foregroundColor(.blue)
                        Text("Dark Mode")
                        Spacer()
                        Toggle("", isOn: .constant(false))
                    }
                    
                    HStack {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                        Text("Auto Refresh")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                // App Info Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2024.1")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Sign Out Section
                Section {
                    Button("Sign Out") {
                        showingSignOutAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    userManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
}

struct PermissionRow: View {
    let title: String
    let isEnabled: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isEnabled ? .green : .red)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserManager())
}