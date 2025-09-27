import SwiftUI

struct FavoriteRecipesView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            Color.FBFBFB.ignoresSafeArea()
            LazyVStack {
                if dataManager.favoritedRecipes.isEmpty {
                    Text("Henüz favori tarifi eklemediniz.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 50)
                } else {
                    ForEach(dataManager.favoritedRecipes) { recipe in
                        Button(action: {
                            navigationPath.append(AppNavigation.recipeDetail(recipe))
                        }) {
                            SearchResultRow(recipe: recipe)
                        }
                        .padding(.horizontal)
                        Divider().padding(.leading)
                    }
                }
            }
        }
        .toolbarBackground(.thinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
                        Text("Geri")
                    }
                    .foregroundStyle(.EBA_72_B)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Favori Tariflerim")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.EBA_72_B)
            }
        }
    }
}
