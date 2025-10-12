import SwiftUI

struct EmailConfirmationView: View {
    @StateObject var viewModel: EmailConfirmationViewModel
    var onConfirmed: () -> Void
    var onNavigateBack: () -> Void
    
    init(email: String, onConfirmed: @escaping () -> Void, onNavigateBack: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: EmailConfirmationViewModel(email: email))
        self.onConfirmed = onConfirmed
        self.onNavigateBack = onNavigateBack
    }
    
    var body: some View {
        ZStack {
            Color.FBFBFB.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.EBA_72_B)
                
                VStack(spacing: 12) {
                    Text("E-postanı Onayla")
                        .font(.largeTitle).fontWeight(.bold).foregroundStyle(._181818)
                    
                    Text("Lütfen e-posta adresine gönderdiğimiz onay bağlantısına tıkla.")
                        .font(.subheadline).foregroundStyle(.A_3_A_3_A_3).multilineTextAlignment(.center)
                }
                
                Text(viewModel.email)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.A_3_A_3_A_3, lineWidth: 1))
                
                if viewModel.isTimerActive {
                    VStack {
                        Text("Tekrar göndermek için bekle:")
                            .font(.caption).foregroundStyle(.A_3_A_3_A_3)
                        
                        CircularTimerView(
                            progress: Double(viewModel.timeRemaining) / Double(viewModel.countdownDuration),
                            timeRemaining: viewModel.timeRemaining
                        )
                        .frame(width: 80, height: 80)
                    }
                    .padding(.top)
                } else {
                    AuthButton(
                        title: "Onay E-postasını Tekrar Gönder",
                        action: { Task { await viewModel.resendConfirmationEmail() } },
                        isLoading: viewModel.isLoading
                    )
                    .padding(.top)
                }
                
                Spacer()
                
                Button("Geri Dön") {
                    onNavigateBack()
                }
                .fontWeight(.bold)
                .tint(.EBA_72_B)
                .font(.footnote)
                .padding(.bottom)
                
            }
            .padding(24)
            .alert("Başarıyla Gönderildi", isPresented: $viewModel.didSendEmail, actions: {
                Button("Tamam") { }
            }, message: { Text("Onay e-postası tekrar gönderildi. Lütfen gelen kutunu ve spam klasörünü kontrol et.")})
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("Tamam") { viewModel.errorMessage = nil }
            }, message: {Text(viewModel.errorMessage ?? "") })
        }
        .onAppear {
            viewModel.startAuthStateListener(onConfirmed: onConfirmed)
            viewModel.startTimer()
        }
    }
}

#Preview {
    EmailConfirmationView(email: "mehmetfurkansakiz@gmail.com", onConfirmed: {}, onNavigateBack: {})
}
