import SwiftUI

struct SplashView: View {
    let coordinator: AppCoordinator
    
    var body: some View {
        VStack {
            Image("cupcake.icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding()
            
            Text("Recipe Buddy")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    SplashView(coordinator: AppCoordinator())
}
