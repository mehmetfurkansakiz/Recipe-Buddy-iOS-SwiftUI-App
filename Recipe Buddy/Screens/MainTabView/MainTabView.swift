import SwiftUI

struct MainTabView: View {
    @StateObject var coordinator: AppCoordinator
    @State private var selectedTab: ContentTab = .home
    @State private var navigationPath = NavigationPath()
    
    private let tabs = [
        TabItem(icon: "home.icon"),
        TabItem(icon: "cupcake.icon"),
        TabItem(icon: "user.icon")
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                // Main content
                TabContent(
                    selectedTab: selectedTab,
                    navigationPath: $navigationPath,
                    coordinator: coordinator
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .ignoresSafeArea(.keyboard)
            
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(recipe: recipe)
            }
            .navigationDestination(for: ShoppingList.self) { _ in
                ShoppingListView(viewModel: ShoppingListViewModel())
            }
            .navigationDestination(for: RecipeCreate.self) { _ in
                RecipeCreateView(viewModel: RecipeCreateViewModel())
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                // TabBar
                CustomTabBar(
                    selectedTab: Binding(
                        get: { selectedTab.rawValue },
                        set: { selectedTab = ContentTab(rawValue: $0)! }
                    ),
                    tabs: tabs
                )
                .padding(.horizontal, 8)
                .padding(.bottom, 64)
            }
        }
        .preferredColorScheme(.light)
    }
}

struct TabContent: View {
    let selectedTab: ContentTab
    @Binding var navigationPath: NavigationPath
    let coordinator: AppCoordinator
    
    var body: some View {
        switch selectedTab {
        case .home:
            HomeView(navigationPath: $navigationPath)
        case .recipe:
            HomeView(navigationPath: $navigationPath)
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    MainTabView(coordinator: AppCoordinator())
}
