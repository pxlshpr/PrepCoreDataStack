import Foundation
import PrepDataTypes

extension DataManager {

    public func getBackendFoods(for searchText: String) async throws -> (foods: [Food], haveMoreResults: Bool) {
        guard let foods = try await getFoods(for: searchText) else {
            return ([], false)
        }
        return (foods, false)
    }
    
    public func getFoods(for searchText: String) async throws -> [Food]? {
        try await withCheckedThrowingContinuation { continuation in
            coreDataManager.fetchFoodsInBackground(for: searchText) { foodEntities in
                guard let foodEntities else {
                    continuation.resume(returning: [])
                    return
                }
                let foods = foodEntities.map { Food(from: $0) }
                continuation.resume(returning: foods)
            }
        }
    }
}
