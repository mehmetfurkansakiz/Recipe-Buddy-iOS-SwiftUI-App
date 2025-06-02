import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @StateObject private var viewModel: RecipeDetailViewModel
    @Environment(\.dismiss) private var dismiss: DismissAction
    
    init(recipe: Recipe) {
        self.recipe = recipe
        _viewModel = StateObject(wrappedValue: RecipeDetailViewModel(recipe: recipe))
        
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
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
                        
                        Spacer(minLength: 120)
                    }
                    .padding()
                }
            }
            .navigationBarBackButtonHidden()
            .ignoresSafeArea(edges: .top)
        }
    }
    
    // MARK: - View Components
    private var recipeImageHeader: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Image(recipe.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                Button(action: {
                    dismiss()
                }) {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(Color("000000").opacity(0.5))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(Color("FFFFFF"))
                            
                    }
                }
                .padding(.leading, 16)
                .padding(.top, 48)
            }
        }
        .frame(minHeight: 300)
    }
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(recipe.name)
                    .font(.largeTitle)
                    .foregroundStyle(Color("181818"))
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleFavorite()
                }) {
                    Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                        .font(.title)
                        .foregroundStyle(viewModel.isFavorite ? Color("FF2A1F") : Color("A3A3A3"))
                }
            }
            
            Text(recipe.description)
                .font(.subheadline)
                .foregroundStyle(Color("303030"))
            
            HStack {
                RecipeInfoBadge(icon: "alarm.icon", text: "\(recipe.cookingTime) dk", color: Color("EBA72B"))
                RecipeInfoBadge(icon: "people.icon", text: "\(recipe.servings)", color: Color("EBA72B"))
                RecipeInfoBadge(icon: "star.fill.icon", text: "\(recipe.rating)",  color: Color("FFCB1F"))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(recipe.categories) { category in
                        Text(category.name)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color("EBA72B").opacity(0.2))
                            .foregroundStyle(Color("EBA72B"))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Malzemeler")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("181818"))
            
            ForEach(recipe.ingredients) { ingredient in
                HStack {
                    Image("circle.fill.icon")
                        .resizable()
                        .foregroundStyle(Color("EBA72B"))
                        .frame(width: 12, height: 12)
                    
                    Text("\(String(format: "%.1f", ingredient.amount)) \(ingredient.unit) \(ingredient.ingredient.name)")
                        .foregroundStyle(Color("303030"))
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.toggleIngredientSelection(ingredient)
                    }) {
                        Image(viewModel.isIngredientSelected(ingredient.ingredient) ? "checkbox.check.icon" : "checkbox.unchecked.icon")
                            .resizable()
                            .foregroundStyle(viewModel.isIngredientSelected(ingredient.ingredient) ? Color("33C759") : Color("A3A3A3"))
                            .frame(width: 18, height: 18)
                    }
                }
                .padding(.vertical, 4)
            }
            
            Button(action: {
                viewModel.toggleAllIngredients()
            }) {
                Text(viewModel.areAllIngredientsSelected ? "Tüm Seçimleri Kaldır" : "Tümünü Seç")
                    .font(.subheadline)
                    .foregroundStyle(Color("EBA72B").opacity(0.8))
            }
            .padding(.top, 8)
        }
    }
    
    private var preparationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hazırlanışı")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("181818"))
            
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top) {
                    Text("\(index + 1).")
                        .font(.headline)
                        .foregroundStyle(Color("A3A3A3"))
                    
                    Text(step)
                        .foregroundStyle(Color("303030"))
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
            VStack {
                HStack(spacing: 8) {
                    Image("cart.icon")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundStyle(Color("FFFFFF"))
                    
                    Text("Seçili Malzemeleri Alışveriş Listesine Ekle")
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("EBA72B"))
            .foregroundStyle(Color("FFFFFF"))
            .cornerRadius(8)
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
    
    return NavigationStack {
        if let firstRecipe = viewModel.recipes.first {
            RecipeDetailView(recipe: firstRecipe)
        }
    }
}
