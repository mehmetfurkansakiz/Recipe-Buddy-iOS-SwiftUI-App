import Foundation
import Combine
import Supabase

@MainActor
class EmailConfirmationViewModel: ObservableObject {
    @Published var email: String
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSendEmail = false
    
    // Timer properties
    @Published var timeRemaining: Int = 60
    @Published var isTimerActive = false
    private var timer: AnyCancellable?
    let countdownDuration = 60
    
    init(email: String) {
        self.email = email
    }
    
    /// Send confirmation email to the user
    func resendConfirmationEmail() async {
        guard !isTimerActive else { return }
        
        isLoading = true
        errorMessage = nil
        didSendEmail = false
        defer { isLoading = false }
        
        do {
            // Supabase send resend confirmation email func
            try await supabase.auth.resend(email: email, type: .signup)
            self.didSendEmail = true
            startTimer()
        } catch {
            self.errorMessage = "Onay e-postası gönderilemedi: \(error.localizedDescription)"
            print("❌ Resend Email Error: \(error)")
        }
    }
    
    /// Listen for auth state changes to detect email confirmation
    func startAuthStateListener(onConfirmed: @escaping () -> Void) {
        Task {
            for await state in supabase.auth.authStateChanges {
                if state.event == .signedIn, state.session != nil {
                    print("✅ Email confirmed and user signed in.")
                    onConfirmed()
                    break
                }
            }
        }
    }
    
    func startTimer() {
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
