import SwiftUI

@main
struct RecipeBuddyApp: App {
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            coordinator.rootView
                .preferredColorScheme(.light)
                .environmentObject(coordinator.dataManager)
        }
    }
}
