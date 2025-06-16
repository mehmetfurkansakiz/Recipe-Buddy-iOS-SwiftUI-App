import SwiftUI

struct SplashView: View {
    let coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Text("Recipe Buddy")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Image(systemName: "fork.knife")
                .font(.system(size: 80))
                .padding()
        }
    }
}
