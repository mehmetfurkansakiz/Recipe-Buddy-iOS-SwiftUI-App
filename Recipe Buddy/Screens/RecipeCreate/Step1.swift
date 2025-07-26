import SwiftUI
import PhotosUI

struct Step1_BasicInfo: View {
    @ObservedObject var viewModel: RecipeCreateViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Image Picker
                PhotosPicker(selection: $viewModel.selectedPhotoItem, matching: .images) {
                    ZStack {
                        if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable().aspectRatio(contentMode: .fill)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("F2F2F7"))
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
                    
                    .frame(height: 250).cornerRadius(12)
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
                
                // Pickers and Toggle
                HStack {
                    Picker("Porsiyon", selection: $viewModel.servings) {
                        ForEach(1...20, id: \.self) { Text("\($0) kişilik").tag($0) }
                    }.pickerStyle(.menu)
                    
                    Picker("Süre", selection: $viewModel.cookingTime) {
                        ForEach(Array(stride(from: 5, through: 240, by: 5)), id: \.self) { Text("\($0) dk").tag($0) }
                    }.pickerStyle(.menu)
                }
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
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 1))
    }
}

struct CustomPickerStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.systemGray4), lineWidth: 1))
    }
}
