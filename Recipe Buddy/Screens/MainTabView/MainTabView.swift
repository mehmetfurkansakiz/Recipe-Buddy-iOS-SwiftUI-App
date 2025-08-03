import SwiftUI

struct MainTabView: View {
    @StateObject var coordinator: AppCoordinator
    @State private var selectedTab: ContentTab = .home
    @State private var navigationPath = NavigationPath()
    @State private var tabBarHeight: CGFloat = 0
    
    private let tabs = [
        TabItem(icon: "home.icon"),
        TabItem(icon: "cupcake.icon"),
        TabItem(icon: "cart.icon"),
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
                .padding(.bottom, tabBarHeight)
                
                // TabBar with GeometryReader
                VStack(spacing: 0) {
                    GeometryReader { geo in
                        CustomTabBar(
                            selectedTab: Binding(
                                get: { selectedTab.rawValue },
                                set: { selectedTab = ContentTab(rawValue: $0)! }
                            ),
                            tabs: tabs
                        )
                        .onAppear {
                            tabBarHeight -= geo.size.height
                        }
                    }
                    .frame(height: 40)
                }
                .padding(.horizontal, 16)
            }
            .ignoresSafeArea(.keyboard)
            
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))
            }
            .navigationDestination(for: RecipeCreate.self) { _ in
                RecipeCreateView(viewModel: RecipeCreateViewModel())
            }
        }
    }
}

struct TabContent: View {
    let selectedTab: ContentTab
    @Binding var navigationPath: NavigationPath
    let coordinator: AppCoordinator
    
    var body: some View {
        switch selectedTab {
        case .home:
            HomeView(viewModel: HomeViewModel(), navigationPath: $navigationPath)
        case .recipe:
            RecipesView(viewModel: RecipesViewModel(), navigationPath: $navigationPath)
        case .shoppingList:
            ShoppingListView(viewModel: ShoppingListViewModel(), navigationPath: $navigationPath)
        case .settings:
            SettingsView(viewModel: SettingsViewModel(coordinator: coordinator), navigationPath: $navigationPath)
        }
    }
}

#Preview {
    MainTabView(coordinator: AppCoordinator())
}
