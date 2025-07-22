import SwiftUI
import PhotosUI
import Supabase

@MainActor
class RecipeCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var servings: Int = 4   // default start
    @Published var cookingTime: Int = 30 // default start
    @Published var steps: [String] = [""]
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
    
    // UI state
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false
    
    let servingsOptions = Array(1...20)
    let timeOptions: [Int] = Array(stride(from: 5, through: 240, by: 5))

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !recipeIngredients.isEmpty &&
        !steps.contains(where: { $0.trimmingCharacters(in: .whitespaces).isEmpty }) &&
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
        guard isValid, let imageData = selectedImageData else {
            self.errorMessage = "Please fill all required fields and select an image."
            return
        }
        
        guard let userId = try? await supabase.auth.session.user.id else {
            self.errorMessage = "You must be logged in to save a recipe."
            return
        }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            // MARK: 1. Upload Image (No change)
            let imagePath = "public/\(UUID().uuidString).jpg"
            try await supabase.storage.from("recipe-images")
                .upload(imagePath, data: imageData, options: FileOptions(contentType: "image/jpeg"))
            
            // MARK: 2. Insert Base Recipe (No change)
            let recipeInsert = NewRecipe(
                name: self.name,
                description: self.description,
                cookingTime: self.cookingTime,
                servings: self.servings,
                steps: self.steps,
                imageName: imagePath,
                userId: userId,
                isPublic: self.isPublic
            )
            
            let savedRecipeInfo: RecipeID = try await supabase.from("recipes")
                .insert(recipeInsert)
                .select("id")
                .single()
                .execute()
                .value
            let newRecipeId = savedRecipeInfo.id
            
            // MARK: 3. Process Ingredients (UPDATED WITH BATCHING)
            var validIngredientLinks: [NewRecipeIngredient] = []
            for ingInput in recipeIngredients {
                let validIngredient = try await findOrCreateIngredient(name: ingInput.ingredient.name)
                let link = NewRecipeIngredient(
                    recipeId: newRecipeId,
                    ingredientId: validIngredient.id,
                    amount: Double(ingInput.amount.replacingOccurrences(of: ",", with: ".")) ?? 0.0,
                    unit: ingInput.unit
                )
                validIngredientLinks.append(link)
            }
            
            let ingredientBatchSize = 50
            for i in stride(from: 0, to: validIngredientLinks.count, by: ingredientBatchSize) {
                let end = min(i + ingredientBatchSize, validIngredientLinks.count)
                let batch = Array(validIngredientLinks[i..<end])
                print("--> Inserting ingredient batch, size: \(batch.count)")
                try await supabase.from("recipe_ingredients").insert(batch).execute()
            }
            
            let recipeCategoryLinks = selectedCategories.map { category in
                NewRecipeCategory(recipeId: newRecipeId, categoryId: category.id)
            }
            
            let categoryBatchSize = 50
            for i in stride(from: 0, to: recipeCategoryLinks.count, by: categoryBatchSize) {
                let end = min(i + categoryBatchSize, recipeCategoryLinks.count)
                let batch = Array(recipeCategoryLinks[i..<end])
                print("--> Inserting category batch, size: \(batch.count)")
                try await supabase.from("recipe_categories").insert(batch).execute()
            }
            
            showSuccess = true
            
        } catch {
            errorMessage = "Failed to save recipe: \(error.localizedDescription)"
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
    
    func addStep() { steps.append("") }
    func removeStep(at index: Int) {
        if steps.count > 1 { steps.remove(at: index) }
    }
}
