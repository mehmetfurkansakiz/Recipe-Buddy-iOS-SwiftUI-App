import Foundation
import Combine
import Supabase

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSendLink = false
    
    // Timer properties
    @Published var timeRemaining = 180
    @Published var isTimerActive = false
    private var timer: AnyCancellable?
    let countdownDuration = 180

    var isFormValid: Bool {
        !email.isEmpty && email.contains("@")
    }

    func sendResetLink() async {
        guard isFormValid else { return }

        isLoading = true
        errorMessage = nil
        didSendLink = false
        defer { isLoading = false }

        do {
            try await supabase.auth.resetPasswordForEmail(email)
            self.didSendLink = true
            startTimer()
        } catch {
            self.errorMessage = "Şifre sıfırlama bağlantısı gönderilemedi: \(error.localizedDescription)"
            print("❌ Forgot Password Error: \(error)")
        }
    }
    
    private func startTimer() {
        isTimerActive = true
        timeRemaining = countdownDuration
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopTimer()
                }
            }
    }
    
    private func stopTimer() {
        isTimerActive = false
        timer?.cancel()
        timer = nil
    }
}
