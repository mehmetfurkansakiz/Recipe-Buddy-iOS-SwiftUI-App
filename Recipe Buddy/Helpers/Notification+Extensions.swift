import Foundation

extension Notification.Name {
    /// Notification posted when a recipe is deleted.
    static let recipeDeleted = Notification.Name("recipeDeletedNotification")
    /// Notification posted when a recipe is updated.
    static let recipeUpdated = Notification.Name("recipeUpdatedNotification")
    /// Notification posted when a recipe is created.
    static let recipeCreated = Notification.Name("recipeCreatedNotification")
}
