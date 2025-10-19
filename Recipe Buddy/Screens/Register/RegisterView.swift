import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    var onRegisterSuccess: (String) -> Void
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
                        AuthTextField(placeholder: "Tam Adınız", text: $viewModel.fullName, contentType: .name)
                        AuthTextField(placeholder: "Kullanıcı Adı", text: $viewModel.username, contentType: .username)
                        AuthTextField(placeholder: "E-posta Adresi", text: $viewModel.email, contentType: .emailAddress)
                            .keyboardType(.emailAddress)
                        AuthTextField(placeholder: "Şifre", text: $viewModel.password, isSecure: true, contentType: .newPassword)
                        AuthTextField(placeholder: "Şifre (Tekrar)", text: $viewModel.confirmPassword, isSecure: true, contentType: .newPassword)
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
                    .onChange(of: viewModel.didRegister) {
                        if viewModel.didRegister {
                            DispatchQueue.main.async {
                                onRegisterSuccess(viewModel.email)
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
                .onTapGesture {
                    endEditing()
                }
            }
        }
    }
}

#Preview {
    RegisterView(onRegisterSuccess: {_ in }, onNavigateToLogin: {})
}

