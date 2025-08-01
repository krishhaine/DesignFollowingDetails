import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    init() {
        checkAuthenticationState()
        setupKumudAccount()
    }
    
    private func checkAuthenticationState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.loadUserData(uid: user.uid)
                }
            }
        }
    }
    
    private func loadUserData(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let document = document, document.exists {
                    self?.currentUser = try? document.data(as: User.self)
                }
            }
        }
    }
    
    private func setupKumudAccount() {
        // Setup default F&B Director account
        let kumudUser = User(
            email: "Kumudkhanal@gmail.com",
            name: "Kumud",
            role: .fbDirector,
            permissions: UserPermissions.permissions(for: .fbDirector),
            createdAt: Date(),
            lastLogin: Date()
        )
        
        // Check if Kumud's account exists, if not create it
        db.collection("users")
            .whereField("email", isEqualTo: "Kumudkhanal@gmail.com")
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error checking for Kumud's account: \(error)")
                    return
                }
                
                if snapshot?.documents.isEmpty == true {
                    // Create Kumud's account
                    do {
                        _ = try self?.db.collection("users").addDocument(from: kumudUser)
                        print("Kumud's account created successfully")
                    } catch {
                        print("Error creating Kumud's account: \(error)")
                    }
                }
            }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let user = result?.user {
                    self?.loadUserData(uid: user.uid)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func canApproveChange(amount: Double) -> Bool {
        guard let user = currentUser else { return false }
        return amount <= user.permissions.approvalThreshold || user.permissions.canOverrideChanges
    }
}