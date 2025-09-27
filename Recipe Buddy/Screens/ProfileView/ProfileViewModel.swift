import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var totalFavoritesReceived: Int = 0
    @Published var averageRating: Double = 0.0
    @Published var isLoading = false
    @Published var isSigningOut = false
    
    private let coordinator: AppCoordinator
    private let recipeService = RecipeService.shared
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    /// Fetches all data needed for the profile screen.
    func fetchAllProfileData(dataManager: DataManager) async {
        isLoading = true
        
        do {
            async let favoriteCountTask = recipeService.fetchTotalFavoritesReceivedCount()
            
            self.totalFavoritesReceived = try await favoriteCountTask
            
            if let user = dataManager.currentUser, let points = user.totalRatingPoints, let received = user.totalRatingsReceived, received > 0 {
                self.averageRating = Double(points) / Double(received)
            } else {
                self.averageRating = 0.0
            }
        } catch {
            print("❌ Error fetching profile data: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    /// Signs the user out.
    func signOut(dataManager: DataManager) async {
        isSigningOut = true
        
        try? await Task.sleep(for: .seconds(1))
        
        do {
            try await supabase.auth.signOut()
            dataManager.clearUserData()
            coordinator.showAuthenticationView()
        } catch {
            print("❌ Error signing out from profile: \(error.localizedDescription)")
            isSigningOut = false
        }
    }
}
