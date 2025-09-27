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
    
    // Pagination for discover recipes
    private var discoverRecipesPage = 1
    private var canLoadMoreRecipes = true
    private var isFetchingMoreRecipes = false
    
    private var cancellables = Set<AnyCancellable>()
    private let recipeService = RecipeService.shared
    
    init() {
        setupSearchDebounce()
        setupCategoryFiltering()
        addObservers()
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
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecipeDeleted), name: .recipeDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleRecipeUpdated), name: .recipeUpdated, object: nil)
    }
    
    @objc private func handleRecipeDeleted(notification: Notification) {
        guard let userInfo = notification.userInfo, let deletedRecipeID = userInfo["recipeID"] as? UUID else { return }
        
        for i in 0..<sections.count {
            sections[i].recipes.removeAll { $0.id == deletedRecipeID }
        }
    }

    @objc private func handleRecipeUpdated(notification: Notification) {
        guard let userInfo = notification.userInfo, let updatedRecipe = userInfo["updatedRecipe"] as? Recipe else { return }
        
        for i in 0..<sections.count {
            if let index = sections[i].recipes.firstIndex(where: { $0.id == updatedRecipe.id }) {
                sections[i].recipes[index] = updatedRecipe
            }
        }
    }

    func fetchHomePageData() async {
        guard sections.isEmpty else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let categoriesTask: () = fetchCategories()
            async let sectionsTask = recipeService.fetchHomeSections()
            
            self.sections = try await sectionsTask
            await categoriesTask
        } catch {
            print("❌ Ana sayfa verileri çekilirken hata: \(error)")
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
            let recipes: [Recipe] = try await supabase
                .rpc("get_recipes_by_category", params: ["cat_id": category.id])
                .select(Recipe.selectQuery)
                .execute()
                .value
            
            self.categoryFilteredRecipes = recipes
            
        } catch {
            print("❌ Kategoriye göre tarif çekilirken hata oluştu: \(category.name), Hata: \(error)")
            self.categoryFilteredRecipes = []
        }
    }
    
    func fetchMoreNewestRecipes() async {
        guard !isFetchingMoreRecipes, canLoadMoreRecipes else { return }
        
        isFetchingMoreRecipes = true
        
        do {
            let newRecipes = try await recipeService.fetchNewestRecipes(page: discoverRecipesPage, limit: 10)
            
            if newRecipes.isEmpty {
                canLoadMoreRecipes = false
            } else {
                if let discoverSectionIndex = sections.firstIndex(where: { $0.style == .standard }) {
                    sections[discoverSectionIndex].recipes.append(contentsOf: newRecipes)
                    discoverRecipesPage += 1
                }
            }
        } catch {
            print("❌ Daha fazla tarif çekilirken hata: \(error)")
        }
        
        isFetchingMoreRecipes = false
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
