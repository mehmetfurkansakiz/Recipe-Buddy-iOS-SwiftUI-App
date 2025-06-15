import Foundation
import Supabase

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didAuthenticate = false
    
    var isSignInFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    func signIn() async {
        guard isSignInFormValid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let _ = try await supabase.auth.signIn(email: email, password: password)

            self.didAuthenticate = true
        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ Sign In Error: \(error)")
        }
    }
}
