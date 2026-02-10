import Foundation
import SwiftUI

@MainActor
class EmailPreferencesViewModel: ObservableObject {
    // UI State
    @Published var emailNewsletter: Bool = false
    @Published var emailProductUpdates: Bool = false
    @Published var emailRecipeTips: Bool = false
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var isInitialLoadCompleted = false
    
    init() {
        Task {
            await loadPreferences()
        }
    }
    
    /// Sunucudan güncel verileri çeker
    func loadPreferences() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let user = try await UserService.shared.fetchCurrentUser() {
                self.emailNewsletter = user.emailNewsletter ?? false
                self.emailProductUpdates = user.emailProductUpdates ?? false
                self.emailRecipeTips = user.emailRecipeTips ?? false
                
                print("📥 [VM] Veriler yüklendi: \(self.emailNewsletter), \(self.emailProductUpdates), \(self.emailRecipeTips)")
            }
        } catch {
            self.errorMessage = "Ayarlar yüklenirken bir hata oluştu."
        }
        
        self.isLoading = false
        self.isInitialLoadCompleted = true
    }
    
    /// Any toogle change triggers save, but only if initial load is done and not currently loading
    func savePreferences() {
        guard isInitialLoadCompleted, !isLoading else { return }
        
        Task {
            do {
                _ = try await UserService.shared.updateEmailPreferences(
                    newsletter: emailNewsletter,
                    productUpdates: emailProductUpdates,
                    recipeTips: emailRecipeTips
                )
            } catch {
                self.errorMessage = "Kaydedilemedi. Lütfen tekrar deneyin."
                await loadPreferences()
            }
        }
    }
}
