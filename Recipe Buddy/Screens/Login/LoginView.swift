import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    var onAuthSuccess: () -> Void
    var onNavigateToRegister: () -> Void
    
    var body: some View {
        ZStack {
            Color("FBFBFB")
                .ignoresSafeArea()
                .onTapGesture {
                     endEditing()
                 }
            
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
                    AuthTextField(placeholder: "E-posta Adresi", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                    AuthTextField(placeholder: "Şifre", text: $viewModel.password, isSecure: true)
                }
                
                // Forgot password link
                HStack {
                    Spacer()
                    Button("Şifremi Unuttum?") {
                        // TODO: Handle forgot password action
                    }
                    .font(.footnote)
                    .tint(Color("EBA72B"))
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
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("Tamam") { viewModel.errorMessage = nil }
            }, message: { Text(viewModel.errorMessage ?? "") })
        }
    }
}

#Preview {
    LoginView(onAuthSuccess: {}, onNavigateToRegister: {})
}
