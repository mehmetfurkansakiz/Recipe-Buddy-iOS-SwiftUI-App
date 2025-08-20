import Foundation
import Supabase

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var recipe: Recipe
    @Published var selectedIngredients: Set<UUID> = []
    @Published var isFavorite: Bool = false
    @Published var showingShoppingListAlert: Bool = false
    @Published var isOwnedByCurrentUser = false
    @Published var isAuthenticated = false
    @Published var isSaving: Bool = false
    @Published var isLoading = true
    @Published var showRatingSheet = false
    @Published var userCurrentRating: Int?
    @Published var showListSelector = false
    @Published var statusMessage: String?
    
    private let recipeService = RecipeService.shared
    
    var areAllIngredientsSelected: Bool {
        selectedIngredients.count == recipe.ingredients.count
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        
        Task {
            await fetchInitialData()
        }
    }
    
    // For preview purposes
    init(recipe: Recipe, isOwnedForPreview: Bool) {
        self.recipe = recipe
        self.isOwnedByCurrentUser = isOwnedForPreview
    }
    
    private func fetchInitialData() async {
        self.isLoading = true
        
        async let authStatusTask: () = checkAuthAndOwnershipStatus()
        async let favoriteStatusTask: () = checkIfFavorite()
        async let userRatingTask: () = fetchUserRating()
        
        // Wait for all checks
        await authStatusTask
        await favoriteStatusTask
        await userRatingTask
        
        self.isLoading = false
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
        do {
            self.isFavorite = try await recipeService.checkIfFavorite(recipeId: recipe.id)
        } catch {
            print("❌ Error checking favorite status: \(error)")
        }
    }
    
    private func fetchUserRating() async {

        do {
            self.userCurrentRating = try await recipeService.fetchUserRating(for: recipe.id)
        } catch {
            print("❌ Error checking favorite status: \(error)")
        }
    }
    
    func isIngredientSelected(_ recipeIngredient: RecipeIngredientJoin) -> Bool {
        guard let id = recipeIngredient.ingredientId else { return false }
        return selectedIngredients.contains(id)
    }
    
    func toggleIngredientSelection(_ recipeIngredient: RecipeIngredientJoin) {
        guard let ingredientId = recipeIngredient.ingredientId else { return }
        
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
                if let ingredientId = recipeIngredient.ingredientId {
                    selectedIngredients.insert(ingredientId)
                }
            }
        }
    }
    
    func toggleFavorite() async {
        isSaving = true
        defer { isSaving = false }
        
        do {
            let newStatus = try await recipeService.toggleFavorite(recipeId: recipe.id)
            self.isFavorite = newStatus
            
            if newStatus {
                recipe.favoritedCount += 1
            } else {
                recipe.favoritedCount -= 1
            }
            
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
    
    /// start adding ingredients to shopping list
    func addSelectedIngredientsToShoppingList() {
        let selected = recipe.ingredients.filter {
            guard let id = $0.ingredientId else { return false }
            return selectedIngredients.contains(id)
        }
        
        guard !selected.isEmpty else {
            statusMessage = "Lütfen önce malzeme seçin."
            return
        }
        
        showListSelector = true
    }
    
    /// selected items add to shopping list
    func add(ingredients: [RecipeIngredientJoin], to list: ShoppingList) async {
        do {
            try await ShoppingListService.shared.addIngredients(ingredients, to: list)
            statusMessage = "'\(list.name)' listesine eklendi!"
        } catch {
            statusMessage = "Hata: Malzemeler eklenemedi."
            print("❌ Error adding ingredients: \(error)")
        }
    }
    
}
