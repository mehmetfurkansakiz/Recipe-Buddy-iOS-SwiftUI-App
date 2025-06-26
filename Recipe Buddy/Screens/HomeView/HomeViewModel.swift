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
    @Published var sections: [RecipeSection] = []
    
    @Published var searchText = ""
    @Published var searchResults: [Recipe] = []
    
    @Published var isLoading = true
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearchDebounce()
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

    func fetchHomePageData() async {
        guard sections.isEmpty else { return }
        
        isLoading = true
        
        async let topRated = fetchSection(title: "Öne Çıkanlar", ordering: "rating", style: .featured)
        async let newest = fetchSection(title: "En Yeniler", ordering: "created_at", style: .standard)
        
        do {
            let fetchedSections = try await [topRated, newest]
            self.sections = fetchedSections.filter { !$0.recipes.isEmpty }
        } catch {
            print("❌ Error fetching home page sections: \(error)")
        }
        
        isLoading = false
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
}
