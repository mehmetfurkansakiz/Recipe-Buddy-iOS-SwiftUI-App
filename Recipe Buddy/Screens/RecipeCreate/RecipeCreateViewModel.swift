import SwiftUI
import PhotosUI

@MainActor
class RecipeCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var description: String = ""
    @Published var servings: Int = 4   // default start
    @Published var cookingTime: Int = 30 // default start
    @Published var steps: [RecipeStep] = [RecipeStep(text: "")]
    @Published var isPublic: Bool = false // default start
    @Published var recipeToEdit: Recipe?
    
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
    @Published var ingredientSearchText = ""
    
    // UI state
    @Published var showSuccess: Bool = false
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false
    @Published var selection: Int = 0
    @Published var showingCategorySelector = false
    @Published var showingIngredientSelector = false
    @Published var showDeleteConfirmAlert = false
    @Published var ingredientAlertMessage: String?
    
    // Service 
    private let recipeService = RecipeService.shared

    // Limits for text inputs
    let nameMaxLength: Int = 60
    let descriptionMaxLength: Int = 240

    func clamp(_ text: String, to max: Int) -> String {
        if text.count > max {
            let idx = text.index(text.startIndex, offsetBy: max)
            return String(text[..<idx])
        }
        return text
    }
    
    // Navigation Title for steps
    var navigationTitle: String {
        switch selection {
        case 0: return "Temel Bilgiler"
        case 1: return "Malzemeler"
        case 2: return "Hazırlanışı"
        default: return "Yeni Tarif"
        }
    }
    
    var filteredIngredients: [Ingredient] {
        if ingredientSearchText.isEmpty {
            return allAvailableIngredients
        } else {
            return allAvailableIngredients.filter {
                $0.name.lowercased().contains(ingredientSearchText.lowercased())
            }
        }
    }
    
    var isCustomAddButtonShown: Bool {
        let trimmedText = ingredientSearchText.trimmingCharacters(in: .whitespaces)
        return !trimmedText.isEmpty && !allAvailableIngredients.contains { $0.name.caseInsensitiveCompare(trimmedText) == .orderedSame }
    }
    
    let servingsOptions = Array(1...20)
    var timeOptions: [Int] {
        var values = Set<Int>()
        func addRange(from: Int, to: Int, step: Int) {
            var v = from
            while v <= to {
                values.insert(v)
                v += step
            }
        }
        // 0-60 dk: 5'er
        addRange(from: 5, to: 60, step: 5)
        // 70-120 dk: 10'ar
        addRange(from: 70, to: 120, step: 10)
        // 135-240 dk: 15'er
        addRange(from: 135, to: 240, step: 15)
        // 240-480 dk (4-8 saat): 30'ar
        addRange(from: 240, to: 480, step: 30)
        // 480-720 dk (8-12 saat): 60'ar
        addRange(from: 480, to: 720, step: 60)
        // 720-1440 dk (12-24 saat): 120'şer
        addRange(from: 720, to: 1440, step: 120)
        // mevcut seçim listede değilse ekle (özellikle düzenleme modunda)
        values.insert(cookingTime)
        return values.sorted()
    }
    
    func formattedDuration(minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 && mins > 0 {
            return "\(hours) saat \(mins) dakika"
        } else if hours > 0 {
            return "\(hours) saat"
        } else {
            return "\(mins) dakika"
        }
    }

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
    
    init(recipeToEdit: Recipe) {
        self.recipeToEdit = recipeToEdit
        Task {
            await fetchInitialData()
            await prepareFieldsForEdit(with: recipeToEdit)
        }
    }
    
    func prepareFieldsForEdit(with recipe: Recipe) async {
        self.name = recipe.name
        self.description = recipe.description
        self.servings = recipe.servings
        self.cookingTime = recipe.cookingTime
        self.isPublic = recipe.isPublic
        self.steps = recipe.steps.map { RecipeStep(text: $0) }
        self.selectedCategories = Set(recipe.categories.map { $0.category })
        
        self.recipeIngredients = recipe.ingredients.map { ingredientJoin in
            let ingredient = Ingredient(id: ingredientJoin.ingredientId ?? UUID(), name: ingredientJoin.name)
            return RecipeIngredientInput(ingredient: ingredient, amount: ingredientJoin.formattedAmount, unit: ingredientJoin.unit)
        }
        
        if let url = recipe.imagePublicURL() {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                self.selectedImageData = data
            } catch {
                print("❌ Image Load Error: \(error)")
            }
        }
    }
    
    func fetchInitialData() async {
        do {
            async let categoriesTask = recipeService.fetchAllCategories()
            async let ingredientsTask = recipeService.fetchAllIngredients()
            
            self.availableCategories = try await categoriesTask
            self.allAvailableIngredients = try await ingredientsTask
        } catch {
            errorMessage = "Gerekli veriler yüklenemedi: \(error.localizedDescription)"
        }
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
            if let recipeToEdit = recipeToEdit {
                let updatedRecipe = try await recipeService.updateRecipe(recipeToEdit.id, viewModel: self)
                NotificationCenter.default.post(name: .recipeUpdated, object: nil, userInfo: ["updatedRecipe": updatedRecipe])
            } else {
                let newRecipe = try await recipeService.createRecipe(viewModel: self)
                NotificationCenter.default.post(name: .recipeCreated, object: nil, userInfo: ["newRecipe": newRecipe])
            }
            showSuccess = true
        } catch {
            errorMessage = "Tarif kaydedilemedi: \(error.localizedDescription)"
            print("❌ Save Error: \(error)")
        }
    }
    
    func deleteRecipe() async {
        guard let recipeToDelete = recipeToEdit else { return }
        
        isSaving = true
        defer { isSaving = false }
        
        do {
            try await recipeService.deleteRecipe(recipeId: recipeToDelete.id, imageName: recipeToDelete.imageName)
            
            NotificationCenter.default.post(name: .recipeDeleted, object: nil, userInfo: ["recipeID": recipeToDelete.id])
            showSuccess = true
        } catch {
            errorMessage = "Tarif silinemedi: \(error.localizedDescription)"
            print("❌ Delete Error: \(error)")
        }
    }
    
    /// Selects an ingredient, checking for duplicates before adding. Also handles custom ingredients.
    func selectIngredient(_ ingredient: Ingredient, isCustom: Bool = false) {
        if !isCustom && recipeIngredients.contains(where: { $0.ingredient.id == ingredient.id }) {
            ingredientAlertMessage = "'\(ingredient.name)' zaten ekli. Miktarını veya birimini değiştirmek için listedeki malzemenin üzerine dokunabilirsiniz."
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

