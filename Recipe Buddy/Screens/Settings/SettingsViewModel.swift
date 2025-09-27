import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var showPremiumAlert = false
    
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
}
