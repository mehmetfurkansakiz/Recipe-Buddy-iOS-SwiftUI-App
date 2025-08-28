import Foundation
import Combine
import Supabase

fileprivate struct FavoritedRecipeResult: Decodable, Hashable {
    let recipe: Recipe
}

@MainActor
class RecipesViewModel: ObservableObject {
    @Published var searchText = ""
    
    func searchResults(from dataManager: DataManager) -> [Recipe] {
        if searchText.isEmpty {
            return []
        }
        let allRecipes = dataManager.ownedRecipes + dataManager.favoritedRecipes
        let uniqueRecipes = allRecipes.removingDuplicates()
        
        return uniqueRecipes.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    private func fetchOwnedRecipes() async throws -> [Recipe] {
        guard let userId = try? await supabase.auth.session.user.id else { return [] }
        
        let response: [Recipe] = try await supabase.from("recipes")
            .select(Recipe.selectQuery)
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }
    
    private func fetchFavoriteRecipes() async throws -> [Recipe] {
        guard let userId = try? await supabase.auth.session.user.id else { return [] }
        
        let response: [FavoritedRecipeResult] = try await supabase.from("favorite_recipes")
            .select("recipe:recipes(\(Recipe.selectQuery))")
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.map { $0.recipe }
    }
}

// array unique element
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
