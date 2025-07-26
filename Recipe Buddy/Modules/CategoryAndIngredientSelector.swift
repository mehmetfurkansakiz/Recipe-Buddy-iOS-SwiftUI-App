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
    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss
    
    var filteredIngredients: [Ingredient] {
        if searchText.isEmpty {
            return viewModel.allAvailableIngredients
        } else {
            return viewModel.allAvailableIngredients.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color("FBFBFB").opacity(0.4)
                .ignoresSafeArea()
            NavigationStack {
                VStack {
                    List {
                        if !searchText.isEmpty && !filteredIngredients.contains(where: { $0.name.lowercased() == searchText.lowercased() }) {
                            Button(action: {
                                let newIngredient = Ingredient(id: UUID(), name: searchText)
                                viewModel.allAvailableIngredients.insert(newIngredient, at: 0)
                                viewModel.addOrUpdateIngredient(RecipeIngredientInput(ingredient: newIngredient))
                                dismiss()
                            }) {
                                HStack {
                                    Image("plus.circle.icon")
                                        .foregroundStyle(Color("EBA72B"))
                                    Text("\"\(searchText)\" olarak yeni malzeme ekle")
                                        .foregroundStyle(Color("EBA72B"))
                                }
                            }
                        }
                        
                        ForEach(filteredIngredients) { ingredient in
                            Button(action: {
                                viewModel.selectIngredientForEditing(ingredient)
                                dismiss()
                            }) {
                                Text(ingredient.name)
                                    .foregroundStyle(Color("181818"))
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .searchable(text: $searchText, prompt: "Malzeme ara...")
                    .scrollContentBackground(.hidden)
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
