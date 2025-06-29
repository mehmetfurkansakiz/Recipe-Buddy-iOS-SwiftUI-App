import SwiftUI
import PhotosUI

struct RecipeCreateView: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    // management sheet presentation
    @State private var showingCategorySelector = false
    @State private var showingIngredientSelector = false
    
    var body: some View {
        ZStack {
            Color("FBFBFB").ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    ImagePickerSection(imageData: $viewModel.selectedImageData, selectedItem: $viewModel.selectedPhotoItem)
                    
                    BasicInfoSection(name: $viewModel.name, description: $viewModel.description, servings: $viewModel.servings, cookingTime: $viewModel.cookingTime, isPublic: $viewModel.isPublic)
                    
                    CategorySelectionSection(selectedCategories: viewModel.selectedCategories, action: {
                        showingCategorySelector = true
                    })
                    
                    IngredientsSection(recipeIngredients: $viewModel.recipeIngredients, addAction: {
                        showingIngredientSelector = true
                    }, deleteAction: viewModel.removeIngredient)
                    
                    StepsSection(steps: $viewModel.steps, addAction: viewModel.addStep, removeAction: viewModel.removeStep)
                    
                    Spacer()
                }
                .padding()
            }
            .onTapGesture {
                endEditing()
            }
            .navigationTitle("Yeni Tarif")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("İptal")
                            .foregroundStyle(Color("EBA72B"))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        Task { await viewModel.saveRecipe() }
                    }) {
                        Text("Kaydet")
                            .foregroundStyle(Color("EBA72B"))
                            .opacity((!viewModel.isValid || viewModel.isSaving) ? 0.4 : 1.0)
                    }
                    .disabled(!viewModel.isValid || viewModel.isSaving)
                }
            }
            .overlay {
                if viewModel.isSaving {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        ProgressView("Kaydediliyor...")
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
            // Sheets
            .sheet(isPresented: $showingCategorySelector) {
                CategorySelectorView(availableCategories: viewModel.availableCategories, selectedCategories: $viewModel.selectedCategories)
            }
            .sheet(isPresented: $showingIngredientSelector) {
                IngredientSelectorView(viewModel: viewModel)
            }
            .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil), actions: {
                Button("Tamam") { viewModel.errorMessage = nil }
            }, message: { Text(viewModel.errorMessage ?? "") })
            .onChange(of: viewModel.showSuccess) {
                if viewModel.showSuccess { dismiss() }
            }
            .onChange(of: viewModel.selectedPhotoItem) {
                Task { await viewModel.loadImage(from: viewModel.selectedPhotoItem) }
            }
        }
        
    }
}

// MARK: - ImagePickerSection
struct ImagePickerSection: View {
    @Binding var imageData: Data?
    @Binding var selectedItem: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            VStack {
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("F2F2F7"))
                            .frame(height: 240)
                            .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                        
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                            Text("Tarif Resmi Seç")
                        }
                        .foregroundColor(Color("A3A3A3"))
                    }
                }
            }
        }
        .tint(Color("EBA72B"))
    }
}

// MARK: - BasicInfoSection
struct BasicInfoSection: View {
    @Binding var name: String
    @Binding var description: String
    @Binding var servings: Int
    @Binding var cookingTime: Int
    @Binding var isPublic: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tarif Detayları")
                .font(.headline)
                .foregroundStyle(Color("181818"))
            Divider()
            TextField("", text: $name, prompt: Text("Tarif Adı").foregroundStyle(Color("A3A3A3")))
                .padding(8)
                .foregroundStyle(Color("181818"))
                .tint(Color("EBA72B"))
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.5)).offset(y: 1)
                        RoundedRectangle(cornerRadius: 8).fill(Color("F2F2F7"))
                    }
                )
            
            TextField("", text: $description, prompt: Text("Açıklama").foregroundStyle(Color("A3A3A3")), axis: .vertical)
                .padding(8)
                .foregroundStyle(Color("181818"))
                .tint(Color("EBA72B"))
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.5)).offset(y: 1)
                        RoundedRectangle(cornerRadius: 8).fill(Color("F2F2F7"))
                    }
                )
            
            HStack {
                Picker("Porsiyon", selection: $servings) {
                    ForEach(1...20, id: \.self) { Text("\($0) kişilik").tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Color("A3A3A3"))
                .background(Color("F2F2F7"))
                .cornerRadius(8)
                .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                
                Picker("Süre", selection: $cookingTime) {
                    ForEach(Array(stride(from: 5, through: 240, by: 5)), id: \.self) { Text("\($0) dk").tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Color("A3A3A3"))
                .background(Color("F2F2F7"))
                .cornerRadius(8)
                .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                
                Toggle(isOn: $isPublic) {
                    Text("Herkese Açık")
                        .foregroundStyle(Color("EBA72B"))
                }
                .tint(Color("EBA72B"))
                .fixedSize()
            }
        }
    }
}

// MARK: - CategorySelectionSection
struct CategorySelectionSection: View {
    var selectedCategories: Set<Category>
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Kategoriler")
                .font(.headline)
                .foregroundStyle(Color("181818"))
            Divider()
            VStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(selectedCategories)) { category in
                            Text(category.name)
                                .foregroundStyle(Color("181818"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 0)
                                .frame(minHeight: 32, alignment: .leading)
                                .background(Color("F2F2F7"))
                                .cornerRadius(8)
                                .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                                .padding(.bottom, 8)
                        }
                    }
                }
                Text("Kategori seçmek için dokun")
                    .foregroundColor(Color("C2C2C2"))
            }
            .onTapGesture {
                action()
            }
        }
    }
}


// MARK: - IngredientsSection
struct IngredientsSection: View {
    @Binding var recipeIngredients: [RecipeIngredientInput]
    var addAction: () -> Void
    var deleteAction: (UUID) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Malzemeler")
                .font(.headline)
                .foregroundStyle(Color("181818"))
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                ForEach($recipeIngredients) { $ingredientInput in
                    HStack {
                        Text(ingredientInput.ingredient.name)
                            .fontWeight(.regular)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, minHeight: 32,alignment: .leading)
                            .background(Color("F2F2F7"))
                            .foregroundStyle(Color("181818"))
                            .cornerRadius(8)
                            .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                        Spacer()
                        TextField("", text: $ingredientInput.amount, prompt: Text("Miktar").foregroundStyle(Color("A3A3A3")))
                            .keyboardType(.decimalPad)
                            .padding(.horizontal, 4)
                            .frame(width: 64, height: 32, alignment: .center)
                            .foregroundStyle(Color("181818"))
                            .background(Color("F2F2F7"))
                            .cornerRadius(8)
                            .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                        TextField("", text: $ingredientInput.unit, prompt: Text("Birim").foregroundStyle(Color("A3A3A3")))
                            .padding(.horizontal, 4)
                            .frame(width: 80, height: 32, alignment: .center)
                            .foregroundStyle(Color("181818"))
                            .background(Color("F2F2F7"))
                            .cornerRadius(8)
                            .shadow(color: Color("000000").opacity(0.4), radius: 1, x: 0, y: 1)
                        Button (action: {
                            deleteAction(ingredientInput.id)
                        }) {
                            Image("minus.circle.icon")
                                .foregroundStyle(Color("EBA72B"))
                        }
                    }
                }
                Text("Malzeme seçmek için dokun")
                    .foregroundColor(Color("C2C2C2"))
                    .onTapGesture {
                        addAction()
                    }
            }
        }
    }
}


// MARK: - StepsSection
struct StepsSection: View {
    @Binding var steps: [String]
    var addAction: () -> Void
    var removeAction: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Hazırlanışı")
                    .font(.headline)
                    .foregroundStyle(Color("181818"))
                Spacer()
                Button("Adım Ekle", action: addAction)
                    .tint(Color("EBA72B"))
            }
            ForEach(steps.indices, id: \.self) { index in
                HStack {
                    Text("\(index + 1).")
                        .foregroundStyle(Color("EBA72B"))
                    TextField("Adımı yazın...", text: $steps[index], prompt: Text("Adımı yazın...").foregroundStyle(Color("A3A3A3")), axis: .vertical)
                        .tint(Color("181818"))
                        .foregroundStyle(Color("181818"))
                    Button(action: { removeAction(index) }) {
                        Image("minus.circle.icon")
                            .foregroundStyle(Color("EBA72B"))
                    }
                    .foregroundColor(.gray)
                    .disabled(steps.count == 1)
                }
            }
        }
    }
}

#Preview {
    RecipeCreateView(viewModel: RecipeCreateViewModel())
}
