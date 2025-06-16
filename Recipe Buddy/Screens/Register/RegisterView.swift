import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    var onAuthSuccess: () -> Void
    var onNavigateToLogin: () -> Void
    
    var body: some View {
        ZStack {
            Color("FBFBFB")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        Text("Aramıza Katıl")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(Color("181818"))
                        Text("Yeni bir hesap oluşturarak tariflerini kaydet")
                            .font(.subheadline)
                            .foregroundStyle(Color("A3A3A3"))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // registration form
                    VStack(spacing: 16) {
                        AuthTextField(placeholder: "Tam Adınız", text: $viewModel.fullName)
                        AuthTextField(placeholder: "Kullanıcı Adı", text: $viewModel.username)
                        AuthTextField(placeholder: "E-posta Adresi", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                        AuthTextField(placeholder: "Şifre", text: $viewModel.password, isSecure: true)
                        AuthTextField(placeholder: "Şifre (Tekrar)", text: $viewModel.confirmPassword, isSecure: true)
                    }
                    
                    AuthButton(
                        title: "Hesap Oluştur",
                        action: { Task { await viewModel.signUp() } },
                        isDisabled: !viewModel.isSignUpFormValid,
                        isLoading: viewModel.isLoading
                    )
                    .padding(.top)
                    
                    Spacer()
                    
                    // navigate to login
                    HStack(spacing: 4) {
                        Text("Zaten bir hesabın var mı?")
                        Button("Giriş Yap") {
                            onNavigateToLogin()
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
}

#Preview {
    RegisterView(onAuthSuccess: {}, onNavigateToLogin: {})
}
