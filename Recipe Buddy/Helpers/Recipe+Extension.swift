import Foundation

// Recipe image extension for get image supabase storage
extension Recipe {
    var imagePublicURL: URL? {
        let urlString = Secrets.supabaseURL
            .absoluteString
            .replacingOccurrences(of: "/rest/v1", with: "")
        let fullURLString = "\(urlString)/storage/v1/object/public/recipe-images/\(self.imageName)"
        return URL(string: fullURLString)
    }
}

// SQL query for selecting recipes with related data
extension Recipe {
    static let selectQuery = """
        id, name, description, steps, cooking_time, servings, rating, rating_count, image_name, user_id, is_public, created_at,
        user:users!recipes_user_id_fkey(id, full_name, username, avatar_url),
        categories:recipe_categories(category:categories(id, name)),
        ingredients:recipe_ingredients(id, name, amount, unit, ingredient_id)
    """
}
