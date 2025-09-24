import SwiftUI

// EndEditing keyboard extension
extension View {
    func endEditing() {
        // (TextField, SecureField etc.) resign first responder
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func shimmering() -> some View {
        self.modifier(ShimmerEffect())
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = -1.5
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.gray.opacity(0.3))
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .gray.opacity(0.3), location: phase),
                        .init(color: .gray.opacity(0.6), location: phase + 0.1),
                        .init(color: .gray.opacity(0.3), location: phase + 0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        phase = 1.5
                    }
                }
            )
            .mask(content)
    }
}
