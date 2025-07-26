import SwiftUI
import PhotosUI

struct Step1_BasicInfo: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Image Picker
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    ZStack {
                        if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable().aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.thinMaterial)
                                    .frame(height: 240)
                                
                                VStack {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.largeTitle)
                                    Text("Tarif Resmi Seç")
                                }
                                .foregroundColor(Color("A3A3A3"))
                            }
                        }
                    }
                    
                    .frame(height: 240).cornerRadius(12)
                }
                .tint(Color("EBA72B"))
                .onChange(of: viewModel.selectedPhotoItem) {
                    Task { await viewModel.loadImage(from: viewModel.selectedPhotoItem) }
                }
                
                // Text Fields
                VStack(spacing: 16) {
                    TextField("Tarif Adı", text: $viewModel.name)
                    TextField("Açıklama (Örn: Annemin meşhur tarifi...)", text: $viewModel.description, axis: .vertical)
                }
                .textFieldStyle(CustomTextFieldStyle())
                
                // Category Selector
                Button(action: { viewModel.showingCategorySelector = true }) {
                    HStack {
                        if viewModel.selectedCategories.isEmpty {
                            Text("Kategori Seç")
                                .foregroundStyle(Color("A3A3A3"))
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(Array(viewModel.selectedCategories)) { category in
                                        Text(category.name)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color("EBA72B").opacity(0.2))
                                            .foregroundStyle(Color("EBA72B"))
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(CustomPickerStyle())
                
                // Pickers and Toggle
                HStack {
                    Picker("Porsiyon", selection: $viewModel.servings) {
                        ForEach(1...20, id: \.self) { Text("\($0) kişilik").tag($0) }
                    }.pickerStyle(.menu)
                    
                    Picker("Süre", selection: $viewModel.cookingTime) {
                        ForEach(Array(stride(from: 5, through: 240, by: 5)), id: \.self) { Text("\($0) dk").tag($0) }
                    }.pickerStyle(.menu)
                }
                .tint(Color("EBA72B"))
                .buttonStyle(CustomPickerStyle())
                
                Toggle("Herkesle Paylaş", isOn: $viewModel.isPublic)
                    .tint(Color("EBA72B"))
            }
            .padding()
        }
    }
}

// Custom styles to match your design
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

struct CustomPickerStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

#Preview {
    Step1_BasicInfo(viewModel: RecipeCreateViewModel())
}
