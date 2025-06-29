import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    @Published var rootView: AnyView
    
    init() {
        self.rootView = AnyView(EmptyView())
        configureNavigationBarAppearance()
        
        self.rootView = AnyView(SplashView(coordinator: self))
        checkAuthenticationStatus()
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "181818") ?? UIColor(named: "000000")!
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "181818") ?? UIColor(named: "000000")!
        ]
        
        UINavigationBar.appearance().tintColor = UIColor(named: "EBA72B")
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    func checkAuthenticationStatus() {
        Task {
            if let session = try? await supabase.auth.session, !session.isExpired {
                // User is authenticated, show main tab view
                print("✅ Kullanıcı giriş yapmış, ana ekrana yönlendiriliyor.")
                showMainTabView()
            } else {
                print("❌ Kullanıcı giriş yapmamış, kimlik doğrulama ekranına yönlendiriliyor.")
                showAuthenticationView()
            }
        }
    }
    
    func showMainTabView() {
        self.rootView = AnyView(
            MainTabView(coordinator: self)
        )
    }
    
    func showAuthenticationView() {
        self.rootView = AnyView(
            AuthenticationView(onAuthSuccess: {
                print("✅ Kimlik doğrulama başarılı, ana ekrana geçiliyor.")
                self.showMainTabView()
            })
        )
    }
}
