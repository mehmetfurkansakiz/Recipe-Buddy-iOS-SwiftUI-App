import SwiftUI

struct MainTabView: View {
    @StateObject var coordinator: AppCoordinator
    @State private var selectedTab: ContentTab = .home
    @State private var navigationPath = NavigationPath()
    @State private var tabBarHeight: CGFloat = 0
    
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
                            tabBarHeight = geo.size.height + 8
                        }
                    }
                    .frame(height: 56)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            .ignoresSafeArea(.keyboard)
            
            .navigationDestination(for: Recipe.self) { recipe in
                RecipeDetailView(viewModel: RecipeDetailViewModel(recipe: recipe))
            }
            .navigationDestination(for: ShoppingList.self) { _ in
                ShoppingListView(viewModel: ShoppingListViewModel())
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
