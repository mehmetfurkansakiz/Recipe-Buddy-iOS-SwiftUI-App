import SwiftUI

struct AuthenticationView: View {
    @State private var currentAuthScreen: AuthScreen = .login
    
    var onAuthSuccess: () -> Void
    
    enum AuthScreen: Equatable {
        case login
        case register
        case forgotPassword
        case emailConfirmation(String)
    }

    var body: some View {
        ZStack {
            if currentAuthScreen == .login {
                LoginView(
                    onAuthSuccess: onAuthSuccess,
                    onNavigateToRegister: {
                        withAnimation(.easeInOut) {
                            currentAuthScreen = .register
                        }
                    }, onNavigateToForgotPassword: {
                        withAnimation(.easeInOut) {
                            currentAuthScreen = .forgotPassword
                        }
                    }
                )
                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
            }

            if currentAuthScreen == .register {
                RegisterView(
                    onRegisterSuccess: { email in
                        withAnimation(.easeInOut) {
                            currentAuthScreen = .emailConfirmation(email)
                        }
                    } ,
                    onNavigateToLogin: {
                        withAnimation(.easeInOut) {
                            currentAuthScreen = .login
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
            
            if currentAuthScreen == .forgotPassword {
                ForgotPasswordView(
                    onNavigateToLogin: {
                        withAnimation(.easeInOut) {
                            currentAuthScreen = .login
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
            
            if case .emailConfirmation(let email) = currentAuthScreen {
                EmailConfirmationView(
                    email: email, onConfirmed: onAuthSuccess, onNavigateBack: {
                        withAnimation(.easeInOut) {
                            currentAuthScreen = .register
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview {
    AuthenticationView(onAuthSuccess: {})
}
