import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var totalFavoritesReceived: Int = 0
    @Published var averageRating: Double = 0.0
    @Published var isLoading = false
    @Published var isSigningOut = false
    
    let coordinator: AppCoordinator
    private let recipeService = RecipeService.shared
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    /// Fetches all data needed for the profile screen.
    func fetchAllProfileData(dataManager: DataManager) async {
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            let count = try await recipeService.fetchTotalFavoritesReceivedCount()
            self.totalFavoritesReceived = count
            
            guard let user = dataManager.currentUser else {
                self.averageRating = 0.0
                return
            }
            
            let points = user.totalRatingPoints ?? 0
            let received = user.totalRatingsReceived ?? 0
            
            if received > 0 {
                self.averageRating = Double(points) / Double(received)
            } else {
                self.averageRating = 0.0
            }
            
        } catch {
            print("❌ Error fetching profile data: \(error.localizedDescription)")
        }
    }
}
