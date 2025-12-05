import Foundation
import Supabase

@MainActor
class RecipeDetailViewModel: ObservableObject {
    // Main data
    @Published var recipe: Recipe
    
    // UI State
    @Published var selectedIngredients: Set<Int> = []
    @Published var isFavorite: Bool = false
    @Published var userCurrentRating: Int?
    
    // Auth & Ownership
    @Published var isOwnedByCurrentUser = false
    @Published var isAuthenticated = false
    
    // UI Control State
    @Published var isSaving: Bool = false
    @Published var showRatingSheet = false
    @Published var showListSelector = false
    @Published var statusMessage: String?
    @Published var shouldDismiss = false
    @Published var showListCreator = false
    @Published var canUndoRatingChange: Bool = false
    
    // Shopping List ViewModel
    @Published var shoppingListViewModel = ShoppingListViewModel()
    
    // Private Properties
    private let recipeId: UUID
    private let recipeService = RecipeService.shared
    private var previousUserRating: Int?
    
    // Computed Properties
    var areAllIngredientsSelected: Bool {
        selectedIngredients.count == recipe.ingredients.count
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
        self.recipeId = recipe.id
        
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRecipeDeleted),
            name: .recipeDeleted,
            object: nil
        )
    }
    
    func loadData() async {
        do {
            let freshRecipe: Recipe = try await supabase.from("recipes")
                .select(Recipe.selectQuery)
                .eq("id", value: self.recipeId)
                .single().execute().value
            
            self.recipe = freshRecipe
            
            async let authStatusTask: () = checkAuthAndOwnershipStatus()
            async let favoriteStatusTask: () = checkIfFavorite()
            async let userRatingTask: () = fetchUserRating()
            
            await authStatusTask
            await favoriteStatusTask
            await userRatingTask
            
        } catch {
            print("❌ Detay verisi çekilirken hata oluştu: \(error)")
            self.shouldDismiss = true
        }
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
    
    private func refreshRecipe() async {
        do {
            let freshRecipe: Recipe = try await supabase.from("recipes")
                .select(Recipe.selectQuery)
                .eq("id", value: self.recipeId)
                .single().execute().value
            self.recipe = freshRecipe
        } catch {
            print("❌ Recipe refresh failed: \(error)")
        }
    }
    
    func isIngredientSelected(_ recipeIngredient: RecipeIngredientJoin) -> Bool {
        return selectedIngredients.contains(recipeIngredient.id)
    }
    
    func toggleIngredientSelection(_ recipeIngredient: RecipeIngredientJoin) {
        let joinId = recipeIngredient.id
        
        if selectedIngredients.contains(joinId) {
            selectedIngredients.remove(joinId)
        } else {
            selectedIngredients.insert(joinId)
        }
    }
    
    func toggleAllIngredients() {
        if areAllIngredientsSelected {
            selectedIngredients.removeAll()
        } else {
            recipe.ingredients.forEach { recipeIngredient in
                selectedIngredients.insert(recipeIngredient.id)
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
                recipe.favoritedCount = max(0, recipe.favoritedCount - 1)
            }
            
            NotificationCenter.default.post(
                name: .favoriteStatusChanged,
                object: nil,
                userInfo: ["recipe": self.recipe, "isFavorite": newStatus]
            )
            
        } catch {
            print("❌ Error toggling favorite: \(error)")
        }
    }
    
    func submitRating(_ rating: Int) async {
        guard let currentUserId = try? await supabase.auth.session.user.id else { return }
        
        self.previousUserRating = self.userCurrentRating
        
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
            self.statusMessage = "Puan kaydedildi"
            self.canUndoRatingChange = true
            await refreshRecipe()
        } catch {
            print("❌ Error submitting rating: \(error)")
        }
    }
    
    func removeRating() async {
        self.previousUserRating = self.userCurrentRating
        
        guard previousUserRating != nil else { return }
        do {
            try await recipeService.deleteUserRating(for: recipe.id)
            self.userCurrentRating = nil
            self.statusMessage = "Puan kaldırıldı"
            self.canUndoRatingChange = true
            await refreshRecipe()
        } catch {
            self.statusMessage = "Puan kaldırılamadı"
            print("❌ Error removing rating: \(error)")
        }
    }
    
    func undoRatingChange() async {
        do {
            if let previous = previousUserRating {
                guard let currentUserId = try? await supabase.auth.session.user.id else { return }
                let ratingData = NewRating(
                    recipeId: self.recipe.id,
                    userId: currentUserId,
                    rating: previous
                )
                try await supabase.from("recipe_ratings")
                    .upsert(ratingData)
                    .execute()
                self.userCurrentRating = previous
            } else {
                try await recipeService.deleteUserRating(for: recipe.id)
                self.userCurrentRating = nil
            }
            self.statusMessage = "Değişiklik geri alındı"
            self.canUndoRatingChange = false
            await refreshRecipe()
        } catch {
            self.statusMessage = "Geri alma başarısız"
            print("❌ Error undoing rating change: \(error)")
        }
    }
    
    /// start adding ingredients to shopping list
    func addSelectedIngredientsToShoppingList() {
        let selected = recipe.ingredients.filter {
            return selectedIngredients.contains($0.id)
        }
        
        guard !selected.isEmpty else {
            statusMessage = "Lütfen önce malzeme seçin."
            return
        }
        
        showListSelector = true
    }
    
    func prepareAndShowListCreator() {
        let selected = recipe.ingredients.filter {
            return selectedIngredients.contains($0.id)
        }
        
        let editableItems = selected.map {
            EditableShoppingItem(
                id: UUID(), // temporary ID for editing UI
                name: $0.name,
                amount: $0.formattedAmount,
                unit: $0.unit,
                originalIngredientId: $0.ingredientId)
        }
        
        shoppingListViewModel.listToEdit = nil
        shoppingListViewModel.listNameForSheet = ""
        shoppingListViewModel.itemsForEditingList = editableItems
        shoppingListViewModel.isShowingEditSheet = true
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
    
    // Listen for recipe deletion notifications
    @objc private func handleRecipeDeleted(notification: Notification) {
        if let userInfo = notification.userInfo, let deletedRecipeID = userInfo["recipeID"] as? UUID {
            print("Recipe with ID \(deletedRecipeID) was deleted.")
            self.shouldDismiss = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
