import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            Color("FBFBFB").ignoresSafeArea()
            // main scrollview
            ScrollView(.vertical, showsIndicators: false) {
                // main vstack
                VStack(alignment: .leading, spacing: 16) {
                    
                    // head and searchbar
                    let usernameToShow = viewModel.currentUser?.fullName ?? viewModel.currentUser?.username ?? ""
                    HeaderView(searchText: $viewModel.searchText, username: ", " + usernameToShow)
                        .padding(.horizontal)
                    
                    // category filter buttons
                    if viewModel.searchText.isEmpty {
                        CategoryScrollView(
                            categories: viewModel.availableCategories,
                            selectedCategory: $viewModel.selectedCategory
                        )
                    }

                    // content area
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                    } else {
                        // search mode or category filtered mode
                        if !viewModel.searchText.isEmpty {
                            SearchResultsView(
                                recipes: viewModel.searchResults,
                                navigationPath: $navigationPath
                            )
                        } else if viewModel.selectedCategory != nil {
                            CategoryResultsView(
                                recipes: viewModel.categoryFilteredRecipes,
                                isLoading: viewModel.isFetchingCategoryRecipes,
                                navigationPath: $navigationPath
                            )
                        } else {
                            // main
                            ForEach(viewModel.sections) { section in
                                RecipeCarouselSection(
                                    title: section.title,
                                    recipes: section.recipes,
                                    style: section.style,
                                    navigationPath: $navigationPath
                                )
                            }
                            .padding(.top)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.fetchHomePageData()
        }
    }
}


// MARK: - Helper Views

struct HeaderView: View {
    @Binding var searchText: String
    let username: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Merhaba\(username) 👋")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color("EBA72B"))
                .shadow(color: Color("000000").opacity(0.1), radius: 8, y: 4)
            Text("Ne pişirmek istersin?")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundStyle(Color("181818"))
                .shadow(color: Color("000000").opacity(0.1), radius: 8, y: 4)
            
            SearchBarView(searchText: $searchText)
        }
    }
}

struct SearchResultsView: View {
    let recipes: [Recipe]
    @Binding var navigationPath: NavigationPath

    var body: some View {
        VStack {
            ForEach(recipes) { recipe in
                Button(action: { navigationPath.append(recipe) }) {
                    SearchResultRow(recipe: recipe)
                }
                .padding(.horizontal)
                Divider().padding(.horizontal)
            }
        }
    }
}

struct CategoryResultsView: View {
    let recipes: [Recipe]
    let isLoading: Bool
    @Binding var navigationPath: NavigationPath

    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
            } else if recipes.isEmpty {
                Text("Bu kategoride tarif bulunamadı.")
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)],
                    spacing: 16
                ) {
                    ForEach(recipes) { recipe in
                        Button(action: { navigationPath.append(recipe) }) {
                            // for use small 
                            let cardWidth = (UIScreen.main.bounds.width / 2) - 24
                            ExploreRecipeCard(recipe: recipe, cardWidth: cardWidth)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct SearchResultRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack {
            AsyncImage(url: recipe.imagePublicURL, transaction: .init(animation: .easeIn)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color("F2F2F7")
                }
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                Text(recipe.name).font(.headline)
                Text("\(recipe.user?.fullName ?? "Mehmet Furkan Sakız")").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}


struct RecipeCarouselSection: View {
    let title: String
    let recipes: [Recipe]
    let style: SectionStyle
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        let cardWidthMultiplier: CGFloat = (style == .featured) ? 0.6 : 0.3
        let cardWidth = UIScreen.main.bounds.width * cardWidthMultiplier
        
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2).bold()
                .padding(.horizontal)
                .foregroundStyle(Color("EBA72B"))
                .shadow(color: Color("000000").opacity(0.1), radius: 8, y: 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        Button(action: { navigationPath.append(recipe) }) {
                            ExploreRecipeCard(recipe: recipe, cardWidth: cardWidth)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


struct ExploreRecipeCard: View {
    let recipe: Recipe
    let cardWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: recipe.imagePublicURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Color("F2F2F7")
                    ProgressView()
                }
            }
            .frame(width: cardWidth, height: cardWidth)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color("000000").opacity(0.1), radius: 8, y: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundStyle(Color("181818"))
                    .lineLimit(1)
                
                Text(recipe.user?.fullName ?? "Anonim")
                    .font(.caption)
                    .foregroundStyle(Color("303030"))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: cardWidth)
    }
}

#Preview {
    HomeView(navigationPath: .constant(NavigationPath()))
        .environmentObject(HomeViewModel())
}
