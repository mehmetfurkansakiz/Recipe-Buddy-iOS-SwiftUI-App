import Foundation
import Supabase

class RecipeDetailViewModel: ObservableObject {
    let recipe: Recipe
    @Published var selectedIngredients: Set<UUID> = []
    @Published var isFavorite: Bool = false
    @Published var showingShoppingListAlert: Bool = false
    @Published var isOwnedByCurrentUser = false
    
    var areAllIngredientsSelected: Bool {
        selectedIngredients.count == recipe.ingredients.count
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        // real application would check favorites from UserDefaults or database
        
        Task {
            await checkOwnership()
        }
    }
    
    // For preview purposes
    init(recipe: Recipe, isOwnedForPreview: Bool) {
        self.recipe = recipe
        self.isOwnedByCurrentUser = isOwnedForPreview
    }
    
    private func checkOwnership() async {
        guard let currentUserId = try? await supabase.auth.session.user.id else {
            self.isOwnedByCurrentUser = false
            return
        }
        
        self.isOwnedByCurrentUser = (currentUserId == self.recipe.userId)
    }
    
    func isIngredientSelected(_ ingredient: Ingredient) -> Bool {
        selectedIngredients.contains(ingredient.id)
    }
    
    func toggleIngredientSelection(_ recipeIngredient: RecipeIngredientJoin) {
        let ingredientId = recipeIngredient.ingredient.id
        if selectedIngredients.contains(ingredientId) {
            selectedIngredients.remove(ingredientId)
        } else {
            selectedIngredients.insert(ingredientId)
        }
    }
    
    func toggleAllIngredients() {
        if areAllIngredientsSelected {
            selectedIngredients.removeAll()
        } else {
            recipe.ingredients.forEach { recipeIngredient in
                selectedIngredients.insert(recipeIngredient.ingredient.id)
            }
        }
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        // real application would save to UserDefaults or database
    }
    
    func addSelectedIngredientsToShoppingList() {
        // real application would use a service to manage the shopping list
        // ShoppingListManager.shared.addItems(selectedItems)
        let selectedItems = recipe.ingredients.filter { recipeIngredient in
            selectedIngredients.contains(recipeIngredient.ingredient.id)
        }.map { recipeIngredient in
            ShoppingItem(
                id: UUID(),
                ingredient: recipeIngredient.ingredient,
                amount: recipeIngredient.amount,
                unit: recipeIngredient.unit,
                userId: nil
            )
        }
        ShoppingListManager.shared.addItems(selectedItems)
    }
}
