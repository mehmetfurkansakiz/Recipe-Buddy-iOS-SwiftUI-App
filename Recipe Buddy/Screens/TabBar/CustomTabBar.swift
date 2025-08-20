import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            
            HStack(spacing: 8) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(tabs[index].icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(selectedTab == index ? Color("EBA72B") : Color("666666"))
                                .frame(width: 24, height: 24)
                        }
                        .frame(width: (screenWidth * 0.9) / CGFloat(tabs.count))
                        .padding(.vertical, 16)
                    }
                }
            }
            .frame(width: screenWidth)
            .background(.regularMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .frame(width: screenWidth, alignment: .center)
        }
    }
}

struct CustomTabBarExample: View {
    @State private var selectedTab = 0
    private let tabs = [
        TabItem(icon: "home.icon"),
        TabItem(icon: "cupcake.icon"),
        TabItem(icon: "cupcake.icon"),
        TabItem(icon: "user.icon")
    ]
    
    var body: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
    }
}

#Preview {
    CustomTabBarExample()
}
