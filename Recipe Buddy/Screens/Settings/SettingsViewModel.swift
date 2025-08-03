import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var isSigningOut = false
    @Published var showPremiumAlert = false
    
    private let coordinator: AppCoordinator
    private let userService = UserService.shared
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }
    
    /// Fetches the current user's profile information.
    func fetchCurrentUser() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            self.currentUser = try await userService.fetchCurrentUser()
        } catch {
            print("❌ Error fetching current user for settings: \(error.localizedDescription)")
        }
    }
    
    /// Signs the user out and triggers the coordinator to show the authentication view.
    func signOut() async {
        isSigningOut = true
        
        try? await Task.sleep(for: .seconds(1))
        
        do {
            try await supabase.auth.signOut()
            // Tell the coordinator to switch back to the login screen
            coordinator.showAuthenticationView()
        } catch {
            print("❌ Error signing out: \(error.localizedDescription)")
            isSigningOut = false
        }
    }
}
