import SwiftUI

struct RecipesView: View {
    @StateObject var viewModel: RecipesViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            SearchBarView(searchText: $viewModel.searchText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            
                            if viewModel.isLoading {
                                Spacer()
                                ProgressView()
                                Spacer()
                            } else {
                                if !viewModel.searchText.isEmpty {
                                    List(viewModel.searchResults) { recipe in
                                        Button(action: { navigationPath.append(recipe) }) {
                                            SearchResultRow(recipe: recipe)
                                        }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                    }
                                    .listStyle(.plain)
                                } else {
                                    ScrollView {
                                        VStack(alignment: .leading, spacing: 30) {
                                            // empty state view
                                            if viewModel.favoritedRecipes.isEmpty && viewModel.ownedRecipes.isEmpty {
                                                emptyStateView
                                            } else {
                                                // Favorites
                                                if !viewModel.favoritedRecipes.isEmpty {
                                                    RecipeCarouselSection(
                                                        title: "Favori Tariflerim",
                                                        recipes: viewModel.favoritedRecipes,
                                                        style: .standard, // Küçük kartlar
                                                        navigationPath: $navigationPath
                                                    )
                                                }
                                                // MyRecipes
                                                if !viewModel.ownedRecipes.isEmpty {
                                                    RecipeCarouselSection(
                                                        title: "Oluşturduğum Tarifler",
                                                        recipes: viewModel.ownedRecipes,
                                                        style: .standard, // Küçük kartlar
                                                        navigationPath: $navigationPath
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .background(Color("FBFBFB"))
                }
                shoppingListButton
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Text("Tarif Oluştur")
                            .font(.headline)
                            .fontWeight(.bold)
                        Image("plus.icon")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .onTapGesture(perform: {
                        navigationPath.append(RecipeCreate())
                    })
                    .foregroundStyle(Color("EBA72B"))
                }
            }
            .task {
                await viewModel.fetchAllMyData()
                
            }
        }
    
    // MARK: - Supporting Views
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 50))
                .foregroundColor(Color("A3A3A3"))
            
            Text("Henüz Tarifiniz Yok")
                .font(.headline)
                .foregroundColor(Color("181818"))
            
            Text("Yeni bir tarif oluşturun veya Ana sayfadan beğendiklerinizi favorilerinize ekleyin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(32)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 50)
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
    RecipesView(viewModel: RecipesViewModel(), navigationPath: .constant(NavigationPath()))
        .environmentObject(RecipesViewModel())
}
