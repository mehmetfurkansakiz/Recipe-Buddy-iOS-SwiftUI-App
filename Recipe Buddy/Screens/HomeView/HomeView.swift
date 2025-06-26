import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        ZStack {
            Color("FBFBFB").ignoresSafeArea()
                    if !viewModel.searchText.isEmpty {
                        VStack {
                            HeaderView(searchText: $viewModel.searchText)
                                .padding(.horizontal)
                            List(viewModel.searchResults) { recipe in
                                Button(action: { navigationPath.append(recipe) }) {
                                    SearchResultRow(recipe: recipe)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                            .listStyle(.plain)
                        }
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 30) {
                                HeaderView(searchText: $viewModel.searchText)
                                    .padding(.horizontal)
                                    .padding(.bottom, 8)
                                
                                if viewModel.isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 50)
                                }
                                ForEach(viewModel.sections) { section in
                                    RecipeCarouselSection(
                                        title: section.title,
                                        recipes: section.recipes,
                                        style: section.style,
                                        navigationPath: $navigationPath
                                    )
                                }
                            }
                        }
                        .padding(.top)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ne pişirmek istersin?")
                .font(.largeTitle).bold()
            
            SearchBarView(searchText: $searchText)
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
                Text("\(recipe.user?.fullName ?? "Anonim")").font(.caption).foregroundStyle(.secondary)
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
            .shadow(color: Color("000000").opacity(0.1), radius: 8, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
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
        }
        .frame(width: cardWidth)
    }
}

#Preview {
    HomeView(navigationPath: .constant(NavigationPath()))
        .environmentObject(HomeViewModel())
}
