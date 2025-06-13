import Foundation
import Combine
import Supabase

@MainActor
class HomeViewModel: ObservableObject {
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
            let query = supabase.from("recipes")
                .select("""
                    *,
                    categories: recipe_categories(* , category: categories(*)),
                    ingredients: recipe_ingredients(id, amount, unit, ingredient: ingredients(*))
                """)
            
            let fetchedRecipes: [Recipe] = try await query.execute().value
            self.recipes = fetchedRecipes
        } catch {
            print("Error fetch recipes: \(error)")
        }
    }
}
