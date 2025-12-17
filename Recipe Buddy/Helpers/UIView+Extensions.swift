import SwiftUI
import UIKit

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

// MARK: - UINavigationBar Configuration
// Reusable bridge to configure UINavigationBar from SwiftUI
struct NavigationBarConfigurator: UIViewControllerRepresentable {
    let configure: (UINavigationController) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            if let nav = controller.navigationController {
                configure(nav)
            }
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension View {
    // Applies an inline navigation bar style with custom title color/font and optional hide-on-swipe
    func inlineColoredNavigationBar(
        titleColor: Color,
        textStyle: UIFont.TextStyle = .headline,
        weight: UIFont.Weight = .bold,
        hidesOnSwipe: Bool = true,
        transparentBackground: Bool = true
    ) -> some View {
        self
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(.automatic, for: .navigationBar)
            .background(
                NavigationBarConfigurator { nav in
                    nav.navigationBar.prefersLargeTitles = false
                    nav.hidesBarsOnSwipe = hidesOnSwipe

                    let appearance = UINavigationBarAppearance()
                    if transparentBackground {
                        appearance.configureWithTransparentBackground()
                    } else {
                        appearance.configureWithDefaultBackground()
                    }

                    // Build a Dynamic Type–aware bold font for the given textStyle
                    let base = UIFont.preferredFont(forTextStyle: textStyle)
                    let font = UIFont.systemFont(ofSize: base.pointSize, weight: weight)
                    let scaledFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)

                    appearance.titleTextAttributes = [
                        .foregroundColor: UIColor(titleColor),
                        .font: scaledFont
                    ]

                    nav.navigationBar.standardAppearance = appearance
                    nav.navigationBar.compactAppearance = appearance
                    nav.navigationBar.scrollEdgeAppearance = appearance
                }
            )
    }
}

