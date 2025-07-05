import SwiftUI

struct RatingView: View {
    @Binding var currentRating: Int?
    let onSave: (Int) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedRating: Int = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Tarife Puan Ver").font(.title2).bold()
            
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= selectedRating ? "star.fill" : "star")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            selectedRating = star
                        }
                }
            }
            
            Button("Puanı Kaydet") {
                onSave(selectedRating)
                dismiss()
            }
            .padding()
            .background(Color("EBA72B"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(selectedRating == 0)
        }
        .onAppear {
            selectedRating = currentRating ?? 0
        }
    }
}
