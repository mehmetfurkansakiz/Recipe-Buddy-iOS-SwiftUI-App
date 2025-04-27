//
//  HomeView.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let padding: CGFloat = 16
                let spacing: CGFloat = 8
                let cardWidth = (screenWidth - (2 * padding) - spacing) / 2
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack() {
                            SearchBarView(searchText: $viewModel.searchText)
                            
                            CategoryScrollView(
                                categories: viewModel.categories,
                                selectedCategory: $viewModel.selectedCategory
                            )
                            
                            recipeGrid(cardWidth: cardWidth, spacing: spacing, padding: padding)
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    shoppingListButton
                }
                .navigationTitle("Recipe Buddy")
                .onAppear {
                    viewModel.loadRecipes()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private func recipeGrid(cardWidth: CGFloat, spacing: CGFloat, padding: CGFloat) -> some View {
        LazyVGrid(
            columns: [
                GridItem(.fixed(cardWidth), spacing: spacing),
                GridItem(.fixed(cardWidth), spacing: spacing)
            ],
            spacing: spacing
        ) {
            ForEach(viewModel.filteredRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeCardView(recipe: recipe, width: cardWidth)
                }
            }
        }
        .padding(.horizontal, padding)
    }
    
    private var shoppingListButton: some View {
        Button(action: {
            viewModel.showShoppingList = true
        }) {
            HStack {
                Image(systemName: "cart")
                Text("Alışveriş Listemi Göster")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("EBA72B"))
            .foregroundStyle(.FFFFFF)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .sheet(isPresented: $viewModel.showShoppingList) {
            ShoppingListView(viewModel: ShoppingListViewModel())
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    HomeView()
}
