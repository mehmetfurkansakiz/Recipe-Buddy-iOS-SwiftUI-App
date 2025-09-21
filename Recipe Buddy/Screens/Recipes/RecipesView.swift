import SwiftUI

struct RecipesView: View {
    @StateObject var viewModel: RecipesViewModel
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                SearchBarView(searchText: $viewModel.searchText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                
                if dataManager.isLoading && dataManager.ownedRecipes.isEmpty {
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
                        mainContent
                    }
                }
            }
            .background(Color.FBFBFB)
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
    
    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                if dataManager.favoritedRecipes.isEmpty && dataManager.ownedRecipes.isEmpty {
                    emptyStateView
                } else {
                    // Favorite Recipes Carousel
                    if !dataManager.favoritedRecipes.isEmpty {
                        RecipeCarouselSection(
                            title: "Favori Tariflerim",
                            recipes: dataManager.favoritedRecipes,
                            style: .standard,
                            navigationPath: $navigationPath
                        )
                    }
                    
                    // My Recipes Grid
                    if !dataManager.ownedRecipes.isEmpty {
                        myRecipesGrid
                    }
                }
            }
            Spacer(minLength: 128)
        }
    }
    
    private var myRecipesGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Oluşturduğum Tarifler")
                .font(.title2).bold()
                .padding(.horizontal)
                .foregroundStyle(Color.EBA_72_B)
            
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
            ) {
                ForEach(dataManager.ownedRecipes) { recipe in
                    Button(action: { navigationPath.append(AppNavigation.recipeDetail(recipe))}) {
                        let cardWidth = (UIScreen.main.bounds.width / 2) - 24
                        ExploreRecipeCard(recipe: recipe, cardWidth: cardWidth)
                    }
                    .onAppear {
                        // Infinite scroll: Load more when reaching the end
                        if recipe.id == dataManager.ownedRecipes.last?.id {
                            Task {
                                await dataManager.fetchMoreOwnedRecipes()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
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
        .environmentObject(DataManager())
}
