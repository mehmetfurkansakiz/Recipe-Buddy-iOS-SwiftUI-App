import SwiftUI

struct Step2_Ingredients: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    @State private var showingIngredientSelector = false
    
    var body: some View {
        VStack {
            List {
                ForEach($viewModel.recipeIngredients) { $item in
                    if viewModel.ingredientToEditDetails?.id == item.id {
                        EditableRecipeIngredientRow(item: $item, onDone: {
                            viewModel.addOrUpdateIngredient(item)
                            viewModel.ingredientToEditDetails = nil
                        })
                        .listRowSeparator(.hidden)
                    } else {
                        Text(item.ingredient.name)
                    }
                }
                .onDelete { indexSet in
                    let idsToDelete = indexSet.map { viewModel.recipeIngredients[$0].id }
                    idsToDelete.forEach { viewModel.removeIngredient(with: $0) }
                }
            }
            .listStyle(.insetGrouped)
            
            Button("Malzeme Ekle") {
                showingIngredientSelector = true
            }
            .buttonStyle(CustomPickerStyle())
            .padding()
        }
        .sheet(isPresented: $showingIngredientSelector) {
            IngredientSelectorView(viewModel: viewModel)
        }
        .animation(.default, value: viewModel.ingredientToEditDetails)
    }
}

// view for the animated editing row
struct EditableRecipeIngredientRow: View {
    @Binding var item: RecipeIngredientInput
    var onDone: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.ingredient.name).font(.headline)
            HStack {
                TextField("Miktar", text: $item.amount)
                    .keyboardType(.decimalPad)
                
                TextField("Birim", text: $item.unit)
                
                Button("Bitti", action: onDone)
                    .buttonStyle(.borderedProminent)
                    .tint(Color("EBA72B"))
            }
            .textFieldStyle(CustomTextFieldStyle())
        }
        .padding()
        .background(Color("EBA72B").opacity(0.1))
        .cornerRadius(12)
    }
}
