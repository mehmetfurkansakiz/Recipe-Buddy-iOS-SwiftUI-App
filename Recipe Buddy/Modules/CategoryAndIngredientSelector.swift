import SwiftUI

struct CategorySelectorView: View {
    let availableCategories: [Category]
    @Binding var selectedCategories: Set<Category>
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("FBFBFB").opacity(0.4)
                .ignoresSafeArea()
            NavigationStack {
                List(availableCategories) { category in
                    HStack {
                        Text(category.name)
                            .foregroundStyle(Color("181818"))
                        Spacer()
                        if selectedCategories.contains(category) {
                            Image("checkbox.check.icon")
                                .foregroundStyle(Color("A3A3A3"))
                        } else {
                            Image("checkbox.unchecked.icon")
                                .foregroundStyle(Color("A3A3A3"))
                        }
                    }
                    .contentShape(Rectangle())
                    .listRowBackground(Color.clear)
                    .onTapGesture {
                        if selectedCategories.contains(category) {
                            selectedCategories.remove(category)
                        } else {
                            selectedCategories.insert(category)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Kategori Seç")
                            .font(.headline)
                            .bold()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Bitti")
                                .foregroundStyle(Color("EBA72B"))
                        }
                        
                    }
                }
            }
        }
    }
}

struct IngredientSelectorView: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("FBFBFB").opacity(0.4)
                .ignoresSafeArea()
            NavigationStack {
                VStack {
                    List {
                        if viewModel.isCustomAddButtonShown {
                             Button(action: {
                                 let trimmedName = viewModel.ingredientSearchText.trimmingCharacters(in: .whitespaces)
                                 let customIngredient = Ingredient(id: UUID(), name: trimmedName)
                                 
                                 viewModel.selectIngredient(customIngredient, isCustom: true)
                                 dismiss()
                             }) {
                                 Label("\"\(viewModel.ingredientSearchText)\" olarak özel malzeme ekle", systemImage: "plus.circle.fill")
                                     .foregroundStyle(Color("EBA72B"))
                             }
                         }
                        
                        ForEach(viewModel.filteredIngredients) { ingredient in
                            Button(action: {
                                viewModel.selectIngredient(ingredient)
                                dismiss()
                            }) {
                                Text(ingredient.name)
                                    .foregroundStyle(Color("181818"))
                            }
                        }
                    }
                    .searchable(text: $viewModel.ingredientSearchText, prompt: "Malzeme ara veya yeni ekle...")
                }
                .navigationTitle("Malzeme Seç")
                .navigationBarItems(trailing: Button(action: {
                    dismiss()
                }) {
                    Text("Bitti")
                        .foregroundStyle(Color("EBA72B"))
                })
            }
        }
    }
}
