import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            SearchBarView(searchText: $viewModel.searchText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            
                            CategoryScrollView(
                                categories: viewModel.categories,
                                selectedCategory: $viewModel.selectedCategory
                            )
                            .padding(.bottom, 8)
                            
                            recipeGrid(
                                cardWidth: (geo.size.width - 16 * 3) / 2,
                                spacing: 16
                            )
                        }
                        .padding(.bottom, 56)
                        // Space between tabbar and scroll view for shoppinglist button
                    }
                    .background(Color("FBFBFB"))
                }
                shoppingListButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .task {
                await viewModel.fetchCategories()
                await viewModel.fetchRecipes()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("Recipe Buddy")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("EBA72B"))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    navigationPath.append(RecipeCreate())
                }) {
                    Image("plus.icon")
                        .resizable()
                        .foregroundStyle(Color("EBA72B"))
                        .frame(width: 24, height: 24)
                }
            }
        }
    }
    
    // MARK: - Recipe Grid
    private func recipeGrid(cardWidth: CGFloat, spacing: CGFloat) -> some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(cardWidth), spacing: spacing),
                    GridItem(.fixed(cardWidth), spacing: spacing)
                ],
                spacing: 0
            ) {
                ForEach(viewModel.filteredRecipes) { recipe in
                    Button {
                        navigationPath.append(recipe)
                    } label: {
                        RecipeCardView(recipe: recipe, width: cardWidth)
                    }
                }
            }
            
            if viewModel.filteredRecipes.isEmpty {
                emptyStateView
            }
        }
    }
    
    // MARK: - Supporting Views
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(Color("A3A3A3"))
            
            Text("Tarif Bulunamadı")
                .font(.headline)
                .foregroundColor(Color("181818"))
            
            Text("Farklı bir arama veya kategori seçimi yapabilirsiniz")
                .font(.subheadline)
                .foregroundColor(Color("A3A3A3"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
    
    private var shoppingListButton: some View {
        Button(action: {
            navigationPath.append(ShoppingList())
        }) {
            HStack {
                Image(systemName: "cart")
                Text("Alışveriş Listemi Göster")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("EBA72B"))
            .foregroundColor(Color("FFFFFF"))
            .cornerRadius(8)
        }
    }
}

#Preview {
    HomeView(navigationPath: .constant(NavigationPath()))
        .environmentObject(HomeViewModel())
}
