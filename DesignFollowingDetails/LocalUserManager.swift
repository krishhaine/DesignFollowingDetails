import Foundation

// Local version without Firebase Auth
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = true // Auto-authenticate for testing
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        // Auto-login with test user
        currentUser = User(
            email: "Kumudkhanal@gmail.com",
            name: "Kumud",
            role: .fbDirector,
            permissions: UserPermissions.permissions(for: .fbDirector),
            createdAt: Date(),
            lastLogin: Date()
        )
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        
        // Simulate login
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isLoading = false
            self.isAuthenticated = true
            self.currentUser = User(
                email: email,
                name: "Test User",
                role: .fbDirector,
                permissions: UserPermissions.permissions(for: .fbDirector),
                createdAt: Date(),
                lastLogin: Date()
            )
        }
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func canApproveChange(amount: Double) -> Bool {
        guard let user = currentUser else { return false }
        return amount <= user.permissions.approvalThreshold || user.permissions.canOverrideChanges
    }
}