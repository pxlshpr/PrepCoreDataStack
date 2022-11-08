import PrepDataTypes
import SwiftSugar

extension DataManager: SearchDataProvider {
    
    public func getFoods(scope: SearchScope, searchText: String, page: Int) async throws -> (foods: [Food], haveMoreResults: Bool) {
        switch scope {
        case .backend:
            return try await getBackendFoods(for: searchText)
        case .verified, .datasets:
            try await sleepTask(Double.random(in: 1...3))
            return (mockFoods, false)
        }
    }
    
    public var recentFoods: [Food] {
        mockFoods
    }
    
    var mockFoods: [Food] {
        [
            Food(mockName: "Cheese", emoji: "🧀"),
            Food(mockName: "KFC Leg", emoji: "🍗"),
            Food(mockName: "Carrot", emoji: "🥕"),
            Food(mockName: "Beans", emoji: "🫘"),
            Food(mockName: "Brinjal", emoji: "🍆"),
        ]
    }
}
