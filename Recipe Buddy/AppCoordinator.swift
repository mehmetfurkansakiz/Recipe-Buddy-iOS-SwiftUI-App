import SwiftUI
import UIKit

@MainActor
class AppCoordinator: ObservableObject {
    @Published var currentView: AppView = .splash
    let dataManager: DataManager
    
    enum AppView {
        case splash
        case auth
        case main
    }
    
    var rootView: AnyView {
        switch currentView {
        case .splash:
            return AnyView(SplashView(coordinator: self))
        case .auth:
            return AnyView(AuthenticationView(onAuthSuccess: {
                Task { await self.setupMainApp()}
            }))
        case .main:
            return AnyView(MainTabView(coordinator: self))
        }
    }
    
    init() {
        let dm = DataManager()
        self.dataManager = dm
        configureNavigationBarAppearance()
        
        listenForAuthStateChanges()
        
        Task {
            await checkAuthenticationStatus()
        }
    }
    
    private func listenForAuthStateChanges() {
        Task {
            for await state in supabase.auth.authStateChanges {
                if state.event == .signedIn, state.session != nil {
                    print("✅ E-posta onayı veya giriş algılandı, ana uygulama kuruluyor...")
                    await setupMainApp()
                }
            }
        }
    }
    
    func checkAuthenticationStatus() async {
        try? await Task.sleep(for: .seconds(1))
        
        do {
            let session = try await supabase.auth.session
            if !session.isExpired {
                await setupMainApp()
            } else {
                showAuthenticationView()
            }
        } catch {
            // User is not authenticated, show authentication view
            print("❌ Kullanıcı giriş yapmamış, kimlik doğrulama ekranına yönlendiriliyor.")
            showAuthenticationView()
        }
    }
    
    private func setupMainApp() async {
        print("✅ Veriler yükleniyor...")
        await dataManager.loadInitialUserData()
        await dataManager.loadHomePageData()
        print("✅ Veriler yüklendi, ana ekrana yönlendiriliyor.")
        currentView = .main
    }
    
    func showAuthenticationView() {
        dataManager.clearUserData()
        currentView = .auth
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
        // Ensure custom back indicator is used during transitions
        if let backImage = UIImage(systemName: "chevron.backward")?.withRenderingMode(.alwaysTemplate) {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        }
        
        UINavigationBar.appearance().tintColor = UIColor(Color.EBA_72_B) 
        UIBarButtonItem.appearance().tintColor = UIColor(Color.EBA_72_B)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

