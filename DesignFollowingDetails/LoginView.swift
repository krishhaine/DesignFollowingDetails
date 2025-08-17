import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var email = "Kumudkhanal@gmail.com"
    @State private var password = "password123"
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo/Header
                VStack(spacing: 10) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("EventSync Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Event Management System")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Login Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Email")
                            .font(.headline)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Button(action: signIn) {
                        HStack {
                            if userManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text("Sign In")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(userManager.isLoading || email.isEmpty || password.isEmpty)
                }
                
                // Quick Login Info
                VStack(spacing: 10) {
                    Text("Demo Account")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Email: Kumudkhanal@gmail.com")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("Password: password123")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Welcome")
            .alert("Login Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(userManager.errorMessage ?? "Unknown error occurred")
            }
            .onChange(of: userManager.errorMessage) { error in
                if error != nil {
                    showingAlert = true
                }
            }
        }
    }
    
    private func signIn() {
        userManager.signIn(email: email, password: password)
    }
}

#Preview {
    LoginView()
        .environmentObject(UserManager())
}