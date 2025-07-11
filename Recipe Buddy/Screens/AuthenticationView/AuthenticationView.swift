import SwiftUI

struct AuthenticationView: View {
    @State private var currentAuthScreen: AuthScreen = .login
    
    var onAuthSuccess: () -> Void
    
    enum AuthScreen {
        case login
        case register
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
                    }
                )
                .transition(.move(edge: .leading))
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
        }
    }
}

#Preview {
    AuthenticationView(onAuthSuccess: {})
}
