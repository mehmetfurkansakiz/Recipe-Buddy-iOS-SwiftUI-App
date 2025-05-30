import SwiftUI

struct RecipeCreateView: View {
    @StateObject var viewModel = RecipeCreateViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Tarif Bilgileri").fontWeight(.bold)) {
                TextField("Tarif Adı", text: $viewModel.name)
                TextField("Açıklama", text: $viewModel.description)
                
                Picker("Kişi Sayısı", selection: $viewModel.servings) {
                    ForEach(viewModel.servingsOptions, id: \.self) { num in
                        Text("\(num)").tag(num)
                    }
                }
                
                Picker("Pişirme Süresi", selection: $viewModel.cookingTime) {
                    ForEach(viewModel.timeOptions, id: \.self) { min in
                        Text("\(min) dakika").tag(min)
                    }
                }
            }
            
            Section(header: Text("Malzemeler").fontWeight(.bold)) {
                ForEach(Array(viewModel.ingredients.enumerated()), id: \.offset) { (idx, ing) in
                    HStack {
                        TextField("Malzeme", text: $viewModel.ingredients[idx].name)
                        TextField("Miktar", text: $viewModel.ingredients[idx].amount)
                            .frame(width: 50)
                        TextField("Birim", text: $viewModel.ingredients[idx].unit)
                            .frame(width: 50)
                        Button(action: { viewModel.removeIngredient(at: idx) }) {
                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                        }
                        .disabled(viewModel.ingredients.count == 1)
                    }
                }
                Button(action: { viewModel.addIngredient() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Malzeme Ekle")
                    }
                }
            }
            
            Section(header: Text("Adımlar").fontWeight(.bold)) {
                ForEach(Array(viewModel.steps.enumerated()), id: \.offset) { (idx, _) in
                    HStack {
                        TextField("Adım", text: $viewModel.steps[idx])
                        Button(action: { viewModel.removeStep(at: idx) }) {
                            Image(systemName: "minus.circle.fill").foregroundColor(.red)
                        }
                        .disabled(viewModel.steps.count == 1)
                    }
                }
                Button(action: { viewModel.addStep() }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Adım Ekle")
                    }
                }
            }
            
            Section {
                Button(action: {
                    viewModel.saveAction()
                    if viewModel.isValid {
                        dismiss()
                    }
                }) {
                    Text("Tarifi Kaydet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isValid ? Color("EBA72B") : Color("A3A3A3"))
                        .foregroundColor(Color("FFFFFF"))
                        .cornerRadius(8)
                }
                .disabled(!viewModel.isValid)
            }
        }
        .navigationTitle("Yeni Tarif")
        .alert("Tarif kaydedildi!", isPresented: $viewModel.showSuccess) {
            Button("Tamam", role: .cancel) {}
        }
    }
}

#Preview {
    RecipeCreateView()
}
