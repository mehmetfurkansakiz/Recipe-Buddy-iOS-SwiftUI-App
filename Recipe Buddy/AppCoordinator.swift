import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var rootView: AnyView
    
    init() {
        self.rootView = AnyView(EmptyView())
        
        configureNavigationBarAppearance()
        
        DispatchQueue.main.async {
            self.rootView = AnyView(SplashView(coordinator: self))
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
    
    func showMainTabView() {
        self.rootView = AnyView(
            MainTabView(coordinator: self)
        )
    }
    
    func showHomeView() {
        showMainTabView()
    }
}
