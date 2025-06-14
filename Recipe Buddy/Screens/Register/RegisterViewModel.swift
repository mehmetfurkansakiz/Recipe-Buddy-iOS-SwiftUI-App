import Foundation
import Supabase

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var username = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didAuthenticate = false
    
    var isSignUpFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !fullName.isEmpty && !username.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    func signUp() async {
        guard isSignUpFormValid else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let _ = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: [
                    "full_name": .string(fullName),
                    "username": .string(username)
                ]
            )
            self.didAuthenticate = true
        } catch {
            self.errorMessage = "Kayıt işlemi başarısız: \(error.localizedDescription)"
            print("❌ Sign Up Error: \(error)")
        }
    }
}
