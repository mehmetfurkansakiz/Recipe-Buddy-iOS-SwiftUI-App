import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    var onAuthSuccess: () -> Void
    var onNavigateToRegister: () -> Void
    var onNavigateToForgotPassword: () -> Void
    
    var body: some View {
        ZStack {
            Color.FBFBFB.ignoresSafeArea().onTapGesture { endEditing() }
            
            VStack(spacing: 20) {
                
                VStack {
                    Image("welcome.chef")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 240)
                    Text("Tekrar Hoş Geldin!")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundStyle(Color("181818"))
                    Text("Kaldığın yerden devam et")
                        .font(.subheadline)
                        .foregroundStyle(Color("A3A3A3"))
                }
                
                // Login form
                VStack(spacing: 16) {
                    AuthTextField(placeholder: "E-posta Adresi", text: $viewModel.email, contentType: .emailAddress)
                        .keyboardType(.emailAddress)
                    AuthTextField(placeholder: "Şifre", text: $viewModel.password, isSecure: true, contentType: .password)
                }
                
                // Forgot password link
                HStack {
                    Spacer()
                    Button("Şifremi Unuttum?") {
                        onNavigateToForgotPassword()
                    }
                    .font(.footnote)
                    .tint(.EBA_72_B)
                }
                
                AuthButton(
                    title: "Giriş Yap",
                    action: { Task { await viewModel.signIn() } },
                    isDisabled: !viewModel.isSignInFormValid,
                    isLoading: viewModel.isLoading
                )
                
                Spacer()
                Spacer()
                
                // Navigate to register
                HStack(spacing: 4) {
                    Text("Hesabın yok mu?")
                    Button("Kayıt Ol") {
                        onNavigateToRegister()
                    }
                    .fontWeight(.bold)
                    .tint(Color("EBA72B"))
                }
                .font(.footnote)
                .padding(.bottom)
                .onChange(of: viewModel.didAuthenticate) {
                    if viewModel.didAuthenticate {
                        DispatchQueue.main.async {
                            onAuthSuccess()
                        }   
                    }
                }
            }
            .padding(.horizontal, 24)
            .alert(item: $viewModel.authError) { error in
                Alert(
                    title: Text("Hata"),
                    message: Text(error.errorDescription ?? "Bilinmeyen bir hata oluştu."),
                    dismissButton: .default(Text("Tamam"))
                )
            }
        }
    }
}

#Preview {
    LoginView(onAuthSuccess: {}, onNavigateToRegister: {}, onNavigateToForgotPassword: {})
}
