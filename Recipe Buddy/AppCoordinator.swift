//
//  Untitled.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

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
        // NavigationBar configure
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        
        // title style
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "181818") ?? UIColor.black
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(named: "181818") ?? UIColor.black
        ]
        
        // back button appearance
        UINavigationBar.appearance().tintColor = UIColor(named: "EBA72B")
        
        // NavigationBar görünümünü ayarla
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    func showHomeView() {
        self.rootView = AnyView(
            HomeView()
                .accentColor(Color("EBA72B")) // SwiftUI 2.0
                .tint(Color("EBA72B")) // SwiftUI 3.0
        )
    }
    
    func showRecipeDetail(recipe: Recipe) {
        self.rootView = AnyView(
            RecipeDetailView(recipe: recipe)
                .accentColor(Color("EBA72B"))
                .tint(Color("EBA72B"))
        )
    }
    
    func showShoppingList() {
        self.rootView = AnyView(
            ShoppingListView(viewModel: ShoppingListViewModel())
                .accentColor(Color("EBA72B"))
                .tint(Color("EBA72B"))
        )
    }
}
