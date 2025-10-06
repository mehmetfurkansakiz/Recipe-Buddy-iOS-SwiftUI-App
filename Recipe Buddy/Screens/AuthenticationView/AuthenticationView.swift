import SwiftUI

struct AuthenticationView: View {
    @State private var currentAuthScreen: AuthScreen = .login
    
    var onAuthSuccess: () -> Void
    
    enum AuthScreen {
        case login
        case register
        case forgotPassword
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
                    onAuthSuccess: onAuthSuccess,
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
        }
    }
}

#Preview {
    AuthenticationView(onAuthSuccess: {})
}
