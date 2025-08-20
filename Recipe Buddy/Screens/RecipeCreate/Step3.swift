import SwiftUI

struct Step3_Preparation: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach($viewModel.steps) { $step in
                    let index = viewModel.steps.firstIndex(of: step) ?? 0
                    
                    HStack(alignment: .top) {
                        Text("\(index + 1).")
                            .font(.headline)
                            .foregroundStyle(Color("EBA72B"))
                            .padding(.top, 12)
                        
                        TextField("Adımı yazın...", text: $step.text, axis: .vertical)
                            .textFieldStyle(CustomTextFieldStyle())
                        
                        if viewModel.steps.count > 1 {
                            Button(action: {
                                viewModel.removeStep(at: index)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundStyle(.red)
                                    .padding(.top, 12)
                            }
                        }
                    }
                }
                
                Button(action: viewModel.addStep) {
                    Label("Yeni Adım Ekle", systemImage: "plus")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(CustomPickerStyle())
                .padding(.top)
                
            }
            .padding()
        }
    }
}
