//
//  RecipeDetailView.swift
//  Recipe Buddy
//
//  Created by furkan sakız on 16.04.2025.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @StateObject private var viewModel: RecipeDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                recipeImageHeader
                
                VStack(alignment: .leading, spacing: 16) {
                    recipeInfoSection
                    
                    Divider()
                    
                    ingredientsSection
                    
                    Divider()
                    
                    preparationSection
                    
                    Divider()
                    
                    addToShoppingListButton
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - View Components
    
    private var recipeImageHeader: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Image(recipe.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 300)
                    .clipped()
                
                // back button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(Color(.FFFFFF))
                        .padding(10)
                        .background(Circle().fill(Color.black.opacity(0.5)))
                }
                .padding(.top, 50)
                .padding(.leading, 16)
            }
        }
        .frame(height: 300)
        .edgesIgnoringSafeArea(.top)
    }
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recipe.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(._181818)
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(viewModel.isFavorite ? .FF_2_A_1_F : .A_3_A_3_A_3)
                }
            }
            
            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(._303030)
            
            HStack {
                RecipeInfoBadge(icon: "clock", text: "\(recipe.cookingTime) dk")
                RecipeInfoBadge(icon: "person.2", text: "\(recipe.servings) kişilik")
                RecipeInfoBadge(icon: "star.fill", text: String(format: "%.1f", recipe.rating))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recipe.categories) { category in
                        Text(category.name)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(.EBA_72_B).opacity(0.2))
                            .foregroundStyle(.EBA_72_B)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Malzemeler")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(._181818)
            
            ForEach(recipe.ingredients) { ingredient in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(.EBA_72_B)
                    
                    Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit) \(ingredient.ingredient.name)")
                        .foregroundStyle(._303030)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleIngredientSelection(ingredient)
                    }) {
                        Image(systemName: viewModel.isIngredientSelected(ingredient.ingredient) ? "checkmark.square.fill" : "square")
                            .foregroundStyle(viewModel.isIngredientSelected(ingredient.ingredient) ? ._33_C_759 : .A_3_A_3_A_3)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Button(action: {
                viewModel.toggleAllIngredients()
            }) {
                Text(viewModel.areAllIngredientsSelected ? "Tüm Seçimleri Kaldır" : "Tümünü Seç")
                    .font(.subheadline)
                    .foregroundStyle(.EBA_72_B).opacity(0.8)
            }
            .padding(.top, 8)
        }
    }
    
    private var preparationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hazırlanışı")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(._181818)
            
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundStyle(.EBA_72_B)
                    
                    Text(step)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(._303030)
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var addToShoppingListButton: some View {
        Button(action: {
            viewModel.addSelectedIngredientsToShoppingList()
            viewModel.showingShoppingListAlert = true
        }) {
            HStack {
                Image(systemName: "cart.badge.plus")
                Text("Seçili Malzemeleri Alışveriş Listesine Ekle")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.EBA_72_B))
            .foregroundStyle(.FFFFFF)
            .cornerRadius(10)
        }
        .disabled(viewModel.selectedIngredients.isEmpty)
        .opacity(viewModel.selectedIngredients.isEmpty ? 0.6 : 1)
        .alert(isPresented: $viewModel.showingShoppingListAlert) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Seçili malzemeler alışveriş listenize eklendi."),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }
}

#Preview {
    let viewModel = HomeViewModel()
    viewModel.loadRecipes()
    
    return NavigationView {
        if let firstRecipe = viewModel.recipes.first {
            RecipeDetailView(recipe: firstRecipe)
        }
    }
}
