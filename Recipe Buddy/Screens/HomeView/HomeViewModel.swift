import Foundation
import Combine
import Supabase

enum SectionStyle {
    case featured
    case standard
}

struct RecipeSection: Identifiable {
    let id = UUID()
    let title: String
    var recipes: [Recipe]
    let style: SectionStyle
}

@MainActor
class HomeViewModel: ObservableObject {
    // Main data
    @Published var currentUser: User?
    @Published var sections: [RecipeSection] = []
    @Published var isLoading = true
    
    // Search
    @Published var searchText = ""
    @Published var searchResults: [Recipe] = []
    
    // Category Filtering
    @Published var availableCategories: [Category] = []
    @Published var selectedCategory: Category?
    @Published var categoryFilteredRecipes: [Recipe] = []
    @Published var isFetchingCategoryRecipes = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchDebounce()
        setupCategoryFiltering()
    }
    
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                if searchText.isEmpty {
                    self.searchResults = []
                } else {
                    Task {
                        await self.searchRecipes(for: searchText)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupCategoryFiltering() {
        $selectedCategory
            .removeDuplicates()
            .sink { [weak self] category in
                guard let self = self else { return }
                
                if let selected = category {
                    Task { await self.fetchRecipes(forCategory: selected) }
                } else {
                    self.categoryFilteredRecipes = []
                }
            }
            .store(in: &cancellables)
    }

    func fetchHomePageData() async {
        guard sections.isEmpty else { return }
        isLoading = true
        
        async let userProfileFetch: () = fetchCurrentUser()
        async let categoriesFetch: () = fetchCategories()
        async let topRated = fetchSection(title: "Öne Çıkanlar", ordering: "rating", style: .featured)
        async let newest = fetchSection(title: "En Yeniler", ordering: "created_at", style: .standard)
        
        do {
            let fetchedSections = try await [topRated, newest]
            await userProfileFetch
            await categoriesFetch
            
            self.sections = fetchedSections.filter { !$0.recipes.isEmpty }
        } catch {
            print("❌ Error fetching home page data: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchCurrentUser() async {
        do {
            guard let userId = try? await supabase.auth.session.user.id else { return }
            
            let user: User = try await supabase.from("users")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value
            
            self.currentUser = user
            
        } catch {
            print("❌ Error fetching current user: \(error)")
        }
    }
    
    func searchRecipes(for query: String) async {
        do {
            let fetchedRecipes: [Recipe] = try await supabase.from("recipes")
                .select(Recipe.selectQuery)
                .eq("is_public", value: true)
                .ilike("name", pattern: "%\(query)%")
                .limit(20)
                .execute()
                .value
            
            self.searchResults = fetchedRecipes
        } catch {
            print("❌ Error searching recipes: \(error)")
        }
    }
    
    func fetchRecipes(forCategory category: Category) async {
        isFetchingCategoryRecipes = true
        defer { isFetchingCategoryRecipes = false }
        
        do {
            // 1. Veriyi önce yardımcı struct dizisine decode et
            let response: [FilteredRecipeResult] = try await supabase
                .from("recipe_categories")
                .select("recipe:recipes(\(Recipe.selectQuery))")
                .eq("category_id", value: category.id)
                .execute()
                .value
            
            self.categoryFilteredRecipes = response.map { $0.recipe }
            
        } catch {
            print("❌ Error fetching recipes for category \(category.name): \(error)")
            self.categoryFilteredRecipes = []
        }
    }
    
    func fetchCategories() async {
        do {
            self.availableCategories = try await supabase.from("categories").select().order("name").execute().value
        } catch {
            print("❌ Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    private func fetchSection(title: String, ordering: String, style: SectionStyle) async throws -> RecipeSection {
        let query = supabase.from("recipes")
            .select(Recipe.selectQuery)
            .eq("is_public", value: true)
        
        let transformedQuery = query
            .order(ordering, ascending: false, nullsFirst: false)
            .limit(10)
        
        let recipes: [Recipe] = try await transformedQuery.execute().value
        
        return RecipeSection(title: title, recipes: recipes, style: style)
    }
    
    enum RecipeFilter { case featured, none }
    fileprivate struct FilteredRecipeResult: Decodable {
        let recipe: Recipe
    }
}
