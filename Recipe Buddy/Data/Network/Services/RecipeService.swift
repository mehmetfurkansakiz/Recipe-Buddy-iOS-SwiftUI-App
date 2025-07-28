import Foundation
import Supabase

@MainActor
class RecipeService {
    static let shared = RecipeService()
    
    // MARK: - Fetch Operations
    
    /// Fetches all available categories.
    func fetchAllCategories() async throws -> [Category] {
        return try await supabase.from("categories").select().order("name").execute().value
    }
    
    /// Fetches all available ingredients.
    func fetchAllIngredients() async throws -> [Ingredient] {
        return try await supabase.from("ingredients").select().order("name").execute().value
    }
    
    /// Fetches all sections for the home page (featured, newest, etc.).
    func fetchHomeSections() async throws -> [RecipeSection] {
        async let topRated = fetchSection(title: "Öne Çıkanlar", ordering: "rating", style: .featured)
        async let newest = fetchSection(title: "En Yeniler", ordering: "created_at", style: .standard)
        
        let fetchedSections = try await [topRated, newest]
        return fetchedSections.filter { !$0.recipes.isEmpty }
    }
    
    /// Fetches recipes created by the current user.
    func fetchOwnedRecipes() async throws -> [Recipe] {
        guard let userId = try? await supabase.auth.session.user.id else { return [] }
        return try await supabase.from("recipes")
            .select(Recipe.selectQuery)
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
    }
    
    /// Fetches recipes favorited by the current user.
    func fetchFavoriteRecipes() async throws -> [Recipe] {
        struct FavoritedRecipeResult: Decodable { let recipe: Recipe }
        guard let userId = try? await supabase.auth.session.user.id else { return [] }
        
        let response: [FavoritedRecipeResult] = try await supabase.from("favorite_recipes")
            .select("recipe:recipes(\(Recipe.selectQuery))")
            .eq("user_id", value: userId)
            .execute()
            .value
        return response.map { $0.recipe }
    }
    
    // MARK: - Recipe Creation
        
        /// Saves a new recipe with all its components.
        func createRecipe(viewModel: RecipeCreateViewModel) async throws {
            guard let userId = try? await supabase.auth.session.user.id,
                  let imageData = viewModel.selectedImageData else {
                throw URLError(.userAuthenticationRequired)
            }
            
            // 1. Upload Image
            let imagePath = "public/\(UUID().uuidString).jpg"
            try await supabase.storage.from("recipe-images")
                .upload(imagePath, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            
            // 2. Insert Base Recipe
            let stepTexts = viewModel.steps.map { $0.text }
            let recipeInsert = NewRecipe(
                name: viewModel.name, description: viewModel.description,
                cookingTime: viewModel.cookingTime, servings: viewModel.servings,
                steps: stepTexts, imageName: imagePath, userId: userId, isPublic: viewModel.isPublic
            )
            let savedRecipeInfo: RecipeID = try await supabase.from("recipes")
                .insert(recipeInsert).select("id").single().execute().value
            let newRecipeId = savedRecipeInfo.id
            
            // 3. Link Ingredients
            let ingredientLinks = viewModel.recipeIngredients.map { ingInput in
                NewRecipeIngredient(
                    recipeId: newRecipeId,
                    name: ingInput.ingredient.name,
                    ingredientId: viewModel.allAvailableIngredients.contains(where: { $0.id == ingInput.ingredient.id }) ? ingInput.ingredient.id : nil,
                    amount: Double(ingInput.amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0,
                    unit: ingInput.unit
                )
            }
            if !ingredientLinks.isEmpty {
                try await supabase.from("recipe_ingredients").insert(ingredientLinks).execute()
            }
            
            // 4. Link Categories
            let recipeCategoryLinks = viewModel.selectedCategories.map {
                NewRecipeCategory(recipeId: newRecipeId, categoryId: $0.id)
            }
            if !recipeCategoryLinks.isEmpty {
                try await supabase.from("recipe_categories").insert(recipeCategoryLinks).execute()
            }
        }
        
        // MARK: - Helper for Sections
        private func fetchSection(title: String, ordering: String, style: SectionStyle) async throws -> RecipeSection {
            let recipes: [Recipe] = try await supabase.from("recipes")
                .select(Recipe.selectQuery)
                .eq("is_public", value: true)
                .order(ordering, ascending: false, nullsFirst: false)
                .limit(10)
                .execute()
                .value
            
            return RecipeSection(title: title, recipes: recipes, style: style)
        }
}
