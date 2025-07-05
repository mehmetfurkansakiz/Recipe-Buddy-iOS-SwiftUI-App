import Foundation
import Supabase

@MainActor
class RecipeDetailViewModel: ObservableObject {
    let recipe: Recipe
    @Published var selectedIngredients: Set<UUID> = []
    @Published var isFavorite: Bool = false
    @Published var showingShoppingListAlert: Bool = false
    @Published var isOwnedByCurrentUser = false
    @Published var isAuthenticated = false
    @Published var isSaving: Bool = false
    @Published var showRatingSheet = false
    @Published var userCurrentRating: Int?
    
    var areAllIngredientsSelected: Bool {
        selectedIngredients.count == recipe.ingredients.count
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        Task {
            await checkAuthAndOwnershipStatus()
            await checkIfFavorite()
            await fetchUserRating()
        }
    }
    
    // For preview purposes
    init(recipe: Recipe, isOwnedForPreview: Bool) {
        self.recipe = recipe
        self.isOwnedByCurrentUser = isOwnedForPreview
    }
    
    private func checkAuthAndOwnershipStatus() async {
        guard let currentUserId = try? await supabase.auth.session.user.id else {
            self.isAuthenticated = false
            self.isOwnedByCurrentUser = false
            return
        }
        self.isAuthenticated = true
        self.isOwnedByCurrentUser = (currentUserId == self.recipe.userId)
    }
    
    private func checkIfFavorite() async {
        guard let currentUserId = try? await supabase.auth.session.user.id else { return }
        
        do {
            let favoritedRecipe: [RecipeID] = try await supabase
                .from("favorite_recipes")
                .select("id:recipe_id")
                .eq("user_id", value: currentUserId)
                .eq("recipe_id", value: self.recipe.id)
                .execute()
                .value
            
            self.isFavorite = !favoritedRecipe.isEmpty
        } catch {
            print("❌ Error checking favorite status: \(error)")
        }
    }
    
    private func fetchUserRating() async {
        guard let currentUserId = try? await supabase.auth.session.user.id else { return }
            
        do {
            let existingRating: [String: Int] = try await supabase.from("recipe_ratings")
                .select("rating")
                .eq("user_id", value: currentUserId)
                .eq("recipe_id", value: self.recipe.id)
                .single()
                .execute()
                .value
            self.userCurrentRating = existingRating["rating"]
        } catch {
            self.userCurrentRating = nil
        }
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
    
    func toggleFavorite() async {
        isSaving = true
        defer { isSaving = false }
        
        guard let currentUserId = try? await supabase.auth.session.user.id else { return }
        
        let isNowFavorited = !self.isFavorite
        do {
            if isNowFavorited {
                try await supabase.from("favorite_recipes")
                    .insert(["user_id": currentUserId, "recipe_id": self.recipe.id])
                    .execute()
            } else {
                try await supabase.from("favorite_recipes")
                    .delete()
                    .eq("user_id", value: currentUserId)
                    .eq("recipe_id", value: self.recipe.id)
                    .execute()
            }
            
            self.isFavorite = isNowFavorited
        } catch {
            print("❌ Error toggling favorite: \(error)")
        }
    }
    
    func submitRating(_ rating: Int) async {
        guard let currentUserId = try? await supabase.auth.session.user.id else { return }
        
        let ratingData = NewRating(
            recipeId: self.recipe.id,
            userId: currentUserId,
            rating: rating
        )
        
        do {
            try await supabase.from("recipe_ratings")
                .upsert(ratingData)
                .execute()
            
            self.userCurrentRating = rating
        } catch {
            print("❌ Error submitting rating: \(error)")
        }
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
