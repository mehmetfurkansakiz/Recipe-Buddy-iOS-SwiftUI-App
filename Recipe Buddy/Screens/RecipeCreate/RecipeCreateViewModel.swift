import SwiftUI
import PhotosUI
import Supabase

@MainActor
class RecipeCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var servings: Int = 4   // default start
    @Published var cookingTime: Int = 30 // default start
    @Published var steps: [RecipeStep] = [RecipeStep(text: "")]
    @Published var isPublic: Bool = false // default start
    
    // Photo management
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImageData: Data?
    
    // Category management
    @Published var availableCategories: [Category] = []
    @Published var selectedCategories: Set<Category> = []
    
    // Ingredients management
    @Published var recipeIngredients: [RecipeIngredientInput] = []
    @Published var allAvailableIngredients: [Ingredient] = []
    @Published var ingredientToEditDetails: RecipeIngredientInput?
    
    // UI state
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false
    @Published var selection: Int = 0
    @Published var showingCategorySelector = false
    @Published var showingIngredientSelector = false
    @Published var IngredientAlertMessage: String?
    
    // Service 
    private let recipeService = RecipeService.shared
    
    // Navigation Title for steps
    var navigationTitle: String {
        switch selection {
        case 0: return "Temel Bilgiler"
        case 1: return "Malzemeler"
        case 2: return "Hazırlanışı"
        default: return "Yeni Tarif"
        }
    }
    
    let servingsOptions = Array(1...20)
    let timeOptions: [Int] = Array(stride(from: 5, through: 240, by: 5))

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !recipeIngredients.isEmpty &&
        !steps.contains(where: { $0.text.trimmingCharacters(in: .whitespaces).isEmpty }) &&
        !selectedCategories.isEmpty &&
        selectedImageData != nil
    }
    
    init() {
        Task {
            await fetchInitialData()
        }
    }
    
    func fetchInitialData() async {
        async let fetchCat: () = fetchCategories()
        async let fetchIng: () = fetchIngredients()
        await fetchCat
        await fetchIng
    }
    
    func fetchCategories() async {
        do {
            self.availableCategories = try await supabase.from("categories").select().execute().value
        } catch { errorMessage = "Kategoriler yüklenemedi: \(error.localizedDescription)" }
    }
    
    func fetchIngredients() async {
        do {
            self.allAvailableIngredients = try await supabase.from("ingredients").select().order("name").execute().value
        } catch { errorMessage = "Malzemeler yüklenemedi: \(error.localizedDescription)" }
    }
    
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        do {
            self.selectedImageData = try await item.loadTransferable(type: Data.self)
        } catch {
            errorMessage = "Resim yüklenemedi: \(error.localizedDescription)"
        }
    }
    
    func saveRecipe() async {
        guard isValid else {
            self.errorMessage = "Lütfen tüm gerekli alanları doldurun ve bir resim seçin."
            return
        }
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await recipeService.createRecipe(viewModel: self)
            showSuccess = true
        } catch {
            errorMessage = "Tarif kaydedilemedi: \(error.localizedDescription)"
            print("❌ Save Error: \(error)")
        }
    }
    
    /// Finds an ingredient by name, or creates it if it doesn't exist.
    private func findOrCreateIngredient(name: String) async throws -> Ingredient {
        let ingredient: Ingredient = try await supabase
            .from("ingredients")
            .upsert(["name": name], onConflict: "name")
            .select()
            .single()
            .execute()
            .value
        
        return ingredient
    }
    
    /// Selects an ingredient, checking for duplicates before adding.
    func selectIngredientForEditing(_ ingredient: Ingredient) {
        if recipeIngredients.contains(where: { $0.ingredient.id == ingredient.id }) {
            IngredientAlertMessage = "\(ingredient.name) zaten ekli. Miktarını veya birimini değiştirmek için listedeki malzemenin üzerine dokunabilirsiniz."
        } else {
            let newItem = RecipeIngredientInput(ingredient: ingredient)
            recipeIngredients.append(newItem)
            ingredientToEditDetails = newItem
        }
    }

    func addOrUpdateIngredient(_ ingredientInput: RecipeIngredientInput) {
        if let index = recipeIngredients.firstIndex(where: { $0.ingredient.id == ingredientInput.ingredient.id }) {
            recipeIngredients[index] = ingredientInput
        } else {
            recipeIngredients.append(ingredientInput)
        }
    }
    
    func removeIngredient(with id: UUID) {
        recipeIngredients.removeAll { $0.id == id }
    }
    
    func addStep() { steps.append(RecipeStep(text: "")) }
    func removeStep(at index: Int) {
        if steps.count > 1 { steps.remove(at: index) }
    }
}
