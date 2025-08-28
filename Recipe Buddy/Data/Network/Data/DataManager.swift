import SwiftUI

@MainActor
class DataManager: ObservableObject {
    // MARK: - Published Properties
    /// published variables to notify views about data changes
    @Published var currentUser: User?
    @Published var ownedRecipes: [Recipe] = []
    @Published var favoritedRecipes: [Recipe] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Services
    private let userService = UserService.shared
    private let recipeService = RecipeService.shared
    
    init() {
        addObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// when user logs in, fetch all necessary data
    func loadInitialUserData() async {
        guard currentUser == nil else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let userTask = userService.fetchCurrentUser()
            async let ownedTask = recipeService.fetchOwnedRecipes()
            async let favoritesTask = recipeService.fetchFavoriteRecipes()
            
            self.currentUser = try await userTask
            self.ownedRecipes = try await ownedTask
            self.favoritedRecipes = try await favoritesTask
            print("✅ DataManager: Tüm kullanıcı verileri başarıyla yüklendi.")
        } catch {
            print("❌ DataManager: Başlangıç verileri çekilirken hata oluştu: \(error)")
        }
    }
    
    /// when user logs out, clear all user-specific data
    func clearUserData() {
        self.currentUser = nil
        self.ownedRecipes = []
        self.favoritedRecipes = []
        print("ℹ️ DataManager: Kullanıcı verileri temizlendi.")
    }
    
    // MARK: - Notification Handlers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecipeDeleted), name: .recipeDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecipeUpdated), name: .recipeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecipeCreated), name: .recipeCreated, object: nil)
    }
    
    @objc private func handleRecipeDeleted(notification: Notification) {
        guard let userInfo = notification.userInfo, let deletedRecipeID = userInfo["recipeID"] as? UUID else { return }
        ownedRecipes.removeAll { $0.id == deletedRecipeID }
        favoritedRecipes.removeAll { $0.id == deletedRecipeID }
    }

    @objc private func handleRecipeUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let updatedRecipe = userInfo["updatedRecipe"] as? Recipe else { return }
        
        if let index = ownedRecipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            ownedRecipes[index] = updatedRecipe
        }
        if let index = favoritedRecipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
            favoritedRecipes[index] = updatedRecipe
        }
    }
    
    @objc private func handleRecipeCreated(notification: Notification) {
        guard let userInfo = notification.userInfo, let newRecipe = userInfo["newRecipe"] as? Recipe else { return }
        // Yeni tarifi listenin başına ekle
        ownedRecipes.insert(newRecipe, at: 0)
    }
}
