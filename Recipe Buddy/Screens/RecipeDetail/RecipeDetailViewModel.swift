import Foundation

class RecipeDetailViewModel: ObservableObject {
    let recipe: Recipe
    @Published var selectedIngredients: Set<UUID> = []
    @Published var isFavorite: Bool = false
    @Published var showingShoppingListAlert: Bool = false
    
    var areAllIngredientsSelected: Bool {
        selectedIngredients.count == recipe.ingredients.count
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        // real application would check favorites from UserDefaults or database
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
