import Foundation

// Recipe image extension for get image S3 storage
extension Recipe {
    func imagePublicURL(width: Int? = nil) -> URL? {
         let cloudfrontDomain = Secrets.cloudfrontDomain
        
         var urlString = "\(cloudfrontDomain)/\(self.imageName)"
         
         if let width = width {
             urlString += "?w=\(width)&q=80"
         }
         
         return URL(string: urlString)
     }
}

// SQL query for selecting recipes with related data
extension Recipe {
    static let selectQuery = """
        id, name, description, steps, cooking_time, servings, rating, rating_count, image_name, user_id, is_public, created_at, favorited_count,
        user:users!recipes_user_id_fkey(
            id,
            full_name,
            username,
            avatar_url,
            email,
            total_rating_points,
            total_ratings_received
        ),
        categories:recipe_categories(category:categories(id, name)),
        ingredients:recipe_ingredients(id, name, amount, unit, ingredient_id)
    """
}
