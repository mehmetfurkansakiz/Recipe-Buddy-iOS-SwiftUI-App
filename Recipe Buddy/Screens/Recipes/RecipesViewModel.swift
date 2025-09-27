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
        let allRecipes = Set(dataManager.ownedRecipes).union(Set(dataManager.favoritedRecipes))
        
        return allRecipes.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
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
