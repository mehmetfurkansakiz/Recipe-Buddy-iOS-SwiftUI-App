import SwiftUI

@MainActor
class AppCoordinator: ObservableObject {
    @Published var rootView: AnyView
    let dataManager: DataManager
    
    init() {
        let dm = DataManager()
        self.dataManager = dm
        
        self.rootView = AnyView(EmptyView())
        configureNavigationBarAppearance()
        
        Task {
            try? await Task.sleep(for: .seconds(1))
            await checkAuthenticationStatus()
        }
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
    
    func checkAuthenticationStatus() async {
        do {
            let session = try await supabase.auth.session
            if !session.isExpired {
                // User is authenticated, show main tab view
                print("✅ Kullanıcı giriş yapmış, veriler yükleniyor...")
                await dataManager.loadInitialUserData()
                await dataManager.loadHomePageData()
                print("✅ Veriler yüklendi, ana ekrana yönlendiriliyor.")
                showMainTabView()
            }
        } catch {
            // User is not authenticated, show authentication view
            print("❌ Kullanıcı giriş yapmamış, kimlik doğrulama ekranına yönlendiriliyor.")
            dataManager.clearUserData()
            showAuthenticationView()
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
                Task {
                    await self.dataManager.loadInitialUserData()
                    await self.dataManager.loadHomePageData()
                    self.showMainTabView()
                }
            })
        )
    }
}
