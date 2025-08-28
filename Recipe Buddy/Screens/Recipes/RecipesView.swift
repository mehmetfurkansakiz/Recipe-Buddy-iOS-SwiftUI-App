import SwiftUI

struct RecipesView: View {
    @StateObject var viewModel: RecipesViewModel
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        SearchBarView(searchText: $viewModel.searchText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        
                        if dataManager.isLoading {
                            Spacer()
                            ProgressView()
                            Spacer()
                        } else {
                            let searchResults = viewModel.searchResults(from: dataManager)
                            if !viewModel.searchText.isEmpty {
                                List(searchResults) { recipe in
                                    Button(action: { navigationPath.append(AppNavigation.recipeDetail(recipe)) }) {
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
                                        if dataManager.favoritedRecipes.isEmpty && dataManager.ownedRecipes.isEmpty {
                                            emptyStateView
                                        } else {
                                            // Favorites
                                            if !dataManager.favoritedRecipes.isEmpty {
                                                RecipeCarouselSection(
                                                    title: "Favori Tariflerim",
                                                    recipes: dataManager.favoritedRecipes,
                                                    style: .standard,
                                                    navigationPath: $navigationPath
                                                )
                                            }
                                            // MyRecipes
                                            if !dataManager.ownedRecipes.isEmpty {
                                                RecipeCarouselSection(
                                                    title: "Oluşturduğum Tarifler",
                                                    recipes: dataManager.ownedRecipes,
                                                    style: .standard,
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
        }
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("Tariflerim")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.EBA_72_B)
            }
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Text("Tarif Oluştur")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.EBA_72_B)
                    Image("plus.icon")
                        .resizable()
                        .foregroundStyle(.EBA_72_B)
                        .frame(width: 24, height: 24)
                }
                .onTapGesture(perform: {
                    navigationPath.append(AppNavigation.recipeCreate)
                })
            }
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
}

#Preview {
    RecipesView(viewModel: RecipesViewModel(), navigationPath: .constant(NavigationPath()))
        .environmentObject(RecipesViewModel())
}
