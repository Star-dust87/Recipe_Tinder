////Created by Stella K on 1/27/26
//  
//  Service for fetching recipes from Edamam API
//

import Foundation

enum RecipeAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case apiKeyMissing
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .apiKeyMissing:
            return "API key is missing. Please configure your API credentials."
        case .rateLimitExceeded:
            return "API rate limit exceeded. Please try again later."
        }
    }
}

class RecipeAPIService {
    static let shared = RecipeAPIService()
    
    // For now, these are placeholders
    private let appId = "YOUR_EDAMAM_APP_ID"
    private let appKey = "YOUR_EDAMAM_APP_KEY"
    private let baseURL = "https://api.edamam.com/api/recipes/v2"
    
    private init() {}
    
    func searchRecipes(
        query: String = "",
        cuisineType: [String] = [],
        mealType: [String] = [],
        dietLabels: [String] = [],
        healthLabels: [String] = [],
        excludeIngredients: [String] = [],
        maxResults: Int = 20
    ) async throws -> [Recipe] {
        
        guard !appId.contains("YOUR_") && !appKey.contains("YOUR_") else {
            throw RecipeAPIError.apiKeyMissing
        }
        
        var components = URLComponents(string: baseURL)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "type", value: "public"),
            URLQueryItem(name: "app_id", value: appId),
            URLQueryItem(name: "app_key", value: appKey),
            URLQueryItem(name: "to", value: String(maxResults))
        ]
        
        if !query.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: query))
        } else {
            queryItems.append(URLQueryItem(name: "q", value: "recipe"))
            queryItems.append(URLQueryItem(name: "random", value: "true"))
        }
        
        for cuisine in cuisineType {
            queryItems.append(URLQueryItem(name: "cuisineType", value: cuisine.lowercased()))
        }
        
        for meal in mealType {
            queryItems.append(URLQueryItem(name: "mealType", value: meal.lowercased()))
        }
        
        for diet in dietLabels {
            queryItems.append(URLQueryItem(name: "diet", value: diet.lowercased()))
        }
        
        for health in healthLabels {
            queryItems.append(URLQueryItem(name: "health", value: health.lowercased()))
        }
        
        for ingredient in excludeIngredients {
            queryItems.append(URLQueryItem(name: "excluded", value: ingredient.lowercased()))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw RecipeAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw RecipeAPIError.invalidResponse
            }
            
            if httpResponse.statusCode == 429 {
                throw RecipeAPIError.rateLimitExceeded
            }
            
            guard httpResponse.statusCode == 200 else {
                throw RecipeAPIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let searchResponse = try decoder.decode(RecipeSearchResponse.self, from: data)
            
            return searchResponse.hits.map { $0.recipe }
            
        } catch let error as DecodingError {
            throw RecipeAPIError.decodingError(error)
        } catch let error as RecipeAPIError {
            throw error
        } catch {
            throw RecipeAPIError.networkError(error)
        }
    }
    
    func getRandomRecipes(count: Int = 20) async throws -> [Recipe] {
        let randomCuisines = ["italian", "mexican", "asian", "american", "mediterranean"]
        let randomCuisine = randomCuisines.randomElement()
        
        return try await searchRecipes(
            cuisineType: randomCuisine.map { [$0] } ?? [],
            maxResults: count
        )
    }
    
    func getPersonalizedRecipes(
        for userProfile: UserProfile,
        count: Int = 20
    ) async throws -> [Recipe] {
        
        return try await searchRecipes(
            cuisineType: userProfile.preferredCuisines,
            dietLabels: userProfile.dietaryRestrictions,
            healthLabels: userProfile.healthPreferences,
            excludeIngredients: userProfile.dislikedIngredients,
            maxResults: count
        )
    }
    
    func fetchRecipeBatch(
        userProfile: UserProfile?,
        batchSize: Int = 20,
        numberOfBatches: Int = 3
    ) async throws -> [Recipe] {
        
        var allRecipes: [Recipe] = []
        
        for _ in 0..<numberOfBatches {
            let recipes: [Recipe]
            
            if let profile = userProfile {
                recipes = try await getPersonalizedRecipes(for: profile, count: batchSize)
            } else {
                recipes = try await getRandomRecipes(count: batchSize)
            }
            
            allRecipes.append(contentsOf: recipes)
            
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        }
        
        var uniqueRecipes: [Recipe] = []
        var seenIds = Set<String>()
        
        for recipe in allRecipes {
            if !seenIds.contains(recipe.id) {
                uniqueRecipes.append(recipe)
                seenIds.insert(recipe.id)
            }
        }
        
        return uniqueRecipes
    }
}

class MockRecipeAPIService {
    func searchRecipes(
        query: String = "",
        cuisineType: [String] = [],
        mealType: [String] = [],
        maxResults: Int = 20
    ) async throws -> [Recipe] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        return Recipe.mockRecipes
    }
    
    func getRandomRecipes(count: Int = 20) async throws -> [Recipe] {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        return Recipe.mockRecipes
    }
}
