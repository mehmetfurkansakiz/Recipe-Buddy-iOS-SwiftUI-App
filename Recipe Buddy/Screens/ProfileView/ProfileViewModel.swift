import Foundation

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var ownedRecipeCount: Int = 0
    @Published var totalFavoritesReceived: Int = 0
    @Published var averageRating: Double = 0.0
    @Published var isLoading = false
    
    private let coordinator: AppCoordinator
    private let userService = UserService.shared
    private let recipeService = RecipeService.shared
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    /// Fetches all data needed for the profile screen.
    func fetchAllProfileData() async {
        isLoading = true
        
        do {
            async let userTask = userService.fetchCurrentUser()
            async let ownedCountTask = recipeService.fetchOwnedRecipeCount()
            async let favoriteCountTask = recipeService.fetchTotalFavoritesReceivedCount()
            
            self.currentUser = try await userTask
            self.ownedRecipeCount = try await ownedCountTask
            self.totalFavoritesReceived = try await favoriteCountTask
            
            if let points = currentUser?.totalRatingPoints, let received = currentUser?.totalRatingsReceived, received > 0 {
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
    func signOut() async {
        // This logic is better suited for the SettingsViewModel,
        // but we can keep a reference here if needed for a logout button on this screen too.
        do {
            try await supabase.auth.signOut()
            coordinator.showAuthenticationView()
        } catch {
            print("❌ Error signing out from profile: \(error.localizedDescription)")
        }
    }
}
