import Foundation
import Combine
import Supabase

@MainActor
class EmailConfirmationViewModel: ObservableObject {
    @Published var email: String
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var didSendEmail = false

    @Published var otpCode: [String]
    let codeLength = 6

    // Timer properties
    @Published var timeRemaining: Int = 60
    @Published var isTimerActive = false
    private var timer: AnyCancellable?
    let countdownDuration = 60

    private var lastOTPSentKey: String { "lastOTPSentTimestamp_\(email)" }

    var isVerifyButtonDisabled: Bool {
        otpCode.joined().count != codeLength || isLoading
    }

    // Detect if running inside Xcode SwiftUI Previews
    private var isRunningInPreview: Bool {
        if let previewFlag = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] {
            return previewFlag == "1" || !previewFlag.isEmpty
        }
        return ProcessInfo.processInfo.arguments.contains("XCODE_RUNNING_FOR_PREVIEWS")
    }

    init(email: String) {
        self.email = email
        self.otpCode = Array(repeating: "", count: codeLength)
    }

    func onAppear(isNewUser: Bool) {
        // Avoid performing network actions during SwiftUI previews
        guard !isRunningInPreview else { return }

        if isNewUser {
            Task { await sendOTP(isResend: false) }
        } else {
            let lastSent = UserDefaults.standard.object(forKey: lastOTPSentKey) as? Date ?? .distantPast
            let timeElapsed = Date().timeIntervalSince(lastSent)

            if timeElapsed >= Double(countdownDuration) {
                Task { await sendOTP(isResend: false) }
            } else {
                let remainingTime = countdownDuration - Int(timeElapsed)
                startTimer(from: remainingTime)
            }
        }
    }

    func sendOTP(isResend: Bool = true) async {
        // Short-circuit network calls in SwiftUI previews and simulate success
        if isRunningInPreview {
            DispatchQueue.main.async {
                self.didSendEmail = true
            }
            return
        }

        guard !isTimerActive else { return }

        isLoading = true
        errorMessage = nil
        didSendEmail = false
        defer { isLoading = false }

        do {
            try await supabase.auth.signInWithOTP(email: email)

            self.didSendEmail = true
            startTimer(from: countdownDuration)
        } catch {
            self.errorMessage = "Onay kodu gönderilemedi: \(error.localizedDescription)"
            print("❌ Send OTP Error: \(error)")
        }
    }

    func verifyOTP() async {
        guard !isVerifyButtonDisabled else { return }

        isLoading = true
        errorMessage = nil
        let token = otpCode.joined()
        defer { isLoading = false }

        do {
            try await supabase.auth.verifyOTP(email: email, token: token, type: .signup)

            print("✅ OTP Başarıyla Doğrulandı.")
            stopTimer()
        } catch {
            print("❌ OTP Doğrulama Hatası: \(error)")
            self.errorMessage = "Girdiğiniz kod hatalı veya süresi dolmuş."
        }
    }

    func startTimer(from startTime: Int) {
        stopTimer()
        isTimerActive = true
        timeRemaining = startTime

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
