import PrepDataTypes
import SwiftSugar

extension DataManager: SearchDataProvider {
    
    public func getFoods(scope: SearchScope, searchText: String, page: Int) async throws -> (foods: [Food], haveMoreResults: Bool) {
        switch scope {
        case .backend:
            return try await getBackendFoods(for: searchText)
        case .verified, .datasets:
            try await sleepTask(Double.random(in: 1...3))
            return ([], false)
        }
    }
    
    public var recentFoods: [Food] {
        myFoods
    }    
}
