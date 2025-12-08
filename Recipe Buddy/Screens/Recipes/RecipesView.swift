import SwiftUI

struct RecipesView: View {
    @StateObject var viewModel: RecipesViewModel
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var dataManager: DataManager
    
    var body: some View {
        ZStack {
            Color("FBFBFB").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    SearchBarView(searchText: $viewModel.searchText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    
                    // Content Area (loading, search results, or main content)
                    if dataManager.isLoading && dataManager.ownedRecipes.isEmpty {
                        ProgressView().padding(.top, 50)
                    } else {
                        let searchResults = viewModel.searchResults(from: dataManager)
                        if !viewModel.searchText.isEmpty {
                            searchResultsContent(for: searchResults)
                        } else {
                            mainContent
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                if dataManager.ownedRecipes.isEmpty && dataManager.favoritedRecipes.isEmpty {
                    await dataManager.loadInitialUserData()
                }
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
        // Navigation title and appearance with helper modifier
        .navigationTitle("Tariflerim")
        .inlineColoredNavigationBar(titleColor: .EBA_72_B, textStyle: .headline, weight: .bold, hidesOnSwipe: true, transparentBackground: true)
    }
    
    // MARK: - Supporting Views
    
    private var mainContent: some View {
        VStack(alignment: .leading, spacing: 30) {
            if dataManager.favoritedRecipes.isEmpty && dataManager.ownedRecipes.isEmpty {
                emptyStateView
            } else {
                favoritesSectionLink
                
                if !dataManager.ownedRecipes.isEmpty {
                    myRecipesGrid
                }
            }
            Spacer(minLength: 128)
        }
    }
    
    /// Search results content
    private func searchResultsContent(for results: [Recipe]) -> some View {
        LazyVStack {
            if results.isEmpty {
                Text("Arama sonucu bulunamadı.")
                    .foregroundStyle(.secondary)
                    .padding(.top, 50)
            } else {
                ForEach(results) { recipe in
                    Button(action: { navigationPath.append(AppNavigation.recipeDetail(recipe)) }) {
                        VStack(spacing: 0) {
                            SearchResultRow(recipe: recipe)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            Divider().padding(.leading)
                        }
                    }
                }
            }
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
    
    private var favoritesSectionLink: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Favori Tariflerim")
                .font(.title2).bold()
                .padding(.horizontal)
                .foregroundStyle(.EBA_72_B)
            
            if dataManager.favoritedRecipes.isEmpty {
                       // if list is empty, show the empty state message
                       VStack(alignment: .leading, spacing: 4) {
                           Text("Henüz favori tarifiniz yok.")
                               .font(.subheadline)
                               .fontWeight(.semibold)
                               .foregroundStyle(._303030)
                           Text("Tariflerin yanındaki ❤️ simgesine tıklayarak favorilerinizi burada görebilirsiniz.")
                               .font(.caption)
                               .foregroundStyle(.A_3_A_3_A_3)
                       }
                       .padding()
                       .frame(maxWidth: .infinity, alignment: .leading)
                       .background(.thinMaterial.opacity(0.3))
                       .clipShape(RoundedRectangle(cornerRadius: 12))
                       .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.A_3_A_3_A_3.opacity(0.5) , lineWidth: 1))
                       .padding(.horizontal)
                       
                   } else {
                       // if list is not empty, show the button to navigate
                       Button(action: {
                           navigationPath.append(AppNavigation.favoriteRecipes)
                       }) {
                           HStack {
                               Text("Tümünü Gör")
                                   .fontWeight(.semibold)
                                   .foregroundStyle(._303030)
                               Spacer()
                               Text("\(dataManager.favoritedRecipes.count) tarif")
                                   .foregroundStyle(.A_3_A_3_A_3)
                               Image(systemName: "chevron.right")
                                   .foregroundStyle(.A_3_A_3_A_3)
                           }
                           .padding()
                           .background(.thinMaterial.opacity(0.3))
                           .clipShape(RoundedRectangle(cornerRadius: 12))
                           .overlay(RoundedRectangle(cornerRadius: 12).stroke(.A_3_A_3_A_3.opacity(0.5) , lineWidth: 1))
                           .padding(.horizontal)
                       }
                   }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 50))
                .foregroundColor(.A_3_A_3_A_3)
            
            Text("Henüz Tarifiniz Yok")
                .font(.headline)
                .foregroundColor(._181818)
            
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

//#Preview {
//    RecipesView(viewModel: RecipesViewModel(), navigationPath: .constant(NavigationPath()))
//        .environmentObject(DataManager())
//}

#Preview {
    // with mock data
    let dataManager = DataManager()
    dataManager.ownedRecipes = Recipe.allMocks.shuffled()
    
    return NavigationStack {
        RecipesView(viewModel: RecipesViewModel(), navigationPath: .constant(NavigationPath()))
            .environmentObject(dataManager)
    }
}
