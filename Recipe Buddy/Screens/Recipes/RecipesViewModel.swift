import Foundation
import Combine
import Supabase

@MainActor
class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var categories: [Category] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: Category?
    
    var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let matchesSearch = searchText.isEmpty ||
                recipe.name.lowercased().contains(searchText.lowercased())

            let matchesCategory = selectedCategory == nil ||
            recipe.categories.contains(where: { $0.category.id == selectedCategory?.id })

            return matchesSearch && matchesCategory
        }
    }
    
    init() {}
    
    func fetchCategories() async {
        do {
            let fetchedCategories: [Category] = try await supabase.from("categories")
                .select()
                .order("name")
                .execute()
                .value
            
            self.categories = fetchedCategories
        } catch {
            print("Error fetch categories: \(error.localizedDescription)")
        }
    }
    
    func fetchRecipes() async {
        do {
            guard let userId = try? await supabase.auth.session.user.id else {
                self.recipes = []
                return
            }
            
            let query = supabase.from("recipes")
                .select(Recipe.selectQuery)
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)

            let fetchedRecipes: [Recipe] = try await query.execute().value
            self.recipes = fetchedRecipes
            
        } catch {
            print("❌ Error fetch my recipes: \(error)")
        }
    }
}
