import Foundation
import Supabase

@MainActor
final class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword: String = ""
    @Published var newPassword: String = ""
    @Published var confirmPassword: String = ""

    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var showSuccess: Bool = false

    var isValid: Bool {
        newPassword.count >= 8 &&
        newPassword == confirmPassword
    }

    func changePassword() async {
        errorMessage = nil
        guard isValid else {
            if newPassword.count < 8 {
                errorMessage = "Yeni şifre en az 8 karakter olmalıdır."
            } else if newPassword != confirmPassword {
                errorMessage = "Şifreler eşleşmiyor."
            } else {
                errorMessage = "Lütfen yeni şifrenizi girin."
            }
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            // Supabase: Update password for the current user (session required)
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            showSuccess = true
            // Clear fields after successful change
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        } catch {
            errorMessage = "Şifre güncellenemedi. Lütfen tekrar deneyin."
            print("❌ ChangePassword: \(error)")
        }
    }
}
