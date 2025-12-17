import Foundation

enum AppNavigation: Hashable {
    case recipeDetail(Recipe)
    case recipeCreate
    case recipeEdit(Recipe)
    case profile
    case favoriteRecipes
    case settings
}
