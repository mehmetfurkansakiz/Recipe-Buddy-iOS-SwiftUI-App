import SwiftUI

struct RecipeCreateView: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom progress indicator for steps
            ProgressHeader(selection: viewModel.selection)
            
            // Page view for each step
            TabView(selection: $viewModel.selection) {
                Step1_BasicInfo(viewModel: viewModel).tag(0)
                Step2_Ingredients(viewModel: viewModel).tag(1)
                Step3_Preparation(viewModel: viewModel).tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // Hides the default dots
            
            // Navigation buttons
            StepNavigation(viewModel: viewModel)
        }
        .animation(.default, value: viewModel.selection) // Animate page transitions
        .navigationTitle(viewModel.navigationTitle)
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
        .sheet(isPresented: $viewModel.showingCategorySelector) {
            CategorySelectorView(availableCategories: viewModel.availableCategories, selectedCategories: $viewModel.selectedCategories)
        }
        .sheet(isPresented: $viewModel.showingIngredientSelector) {
            IngredientSelectorView(viewModel: viewModel)
        }
        .alert("Hata", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("Tamam") { viewModel.errorMessage = nil }
        }, message: { Text(viewModel.errorMessage ?? "") })
        .onChange(of: viewModel.showSuccess) {
            if viewModel.showSuccess { dismiss() }
        }
    }
}

struct ProgressHeader: View {
    let selection: Int
    let steps = ["Temel Bilgiler", "Malzemeler", "Hazırlanışı"]
    
    var body: some View {
        HStack {
            ForEach(steps.indices, id: \.self) { index in
                VStack(spacing: 8) {
                    Text(steps[index])
                        .font(.caption)
                        .foregroundStyle(selection >= index ? Color("EBA72B") : .secondary)
                    
                    Capsule()
                        .fill(selection >= index ? Color("EBA72B") : Color(.systemGray4))
                        .frame(height: 4)
                }
            }
        }
        .padding()
        .background(.thinMaterial)
    }
}

struct StepNavigation: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    
    var body: some View {
        HStack {
            if viewModel.selection > 0 {
                Button { viewModel.selection -= 1 } label: {
                    Label("Geri", systemImage: "chevron.left")
                        .padding().frame(maxWidth: .infinity)
                }
                .background(.gray.opacity(0.2))
                .clipShape(Capsule())
                .contentShape(Rectangle())
            }
            
            if viewModel.selection < 2 {
                Button { viewModel.selection += 1 } label: {
                    HStack(spacing: 4) {
                        Text("İleri")
                        Image(systemName: "chevron.right")
                    }
                    .padding().frame(maxWidth: .infinity)
                }
                .background(Color("EBA72B"))
                .foregroundStyle(.white)
                .clipShape(Capsule())
                .contentShape(Rectangle())
            }
        }
        .padding([.horizontal, .bottom])
        .padding(.top, 8)
        .background(.thinMaterial)
    }
}

#Preview {
    RecipeCreateView(viewModel: RecipeCreateViewModel())
}
