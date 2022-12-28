import Foundation
import PrepDataTypes
import SwiftSugar

extension DataManager: SearchDataProvider {
    
    public func getFoods(scope: SearchScope, searchText: String, page: Int) async throws -> (foods: [Food], haveMoreResults: Bool) {
        switch scope {
        case .backend:
            return try await getBackendFoods(for: searchText)
        case .datasets:
            try await sleepTask(Double.random(in: 1...3))
            return ([], false)
        case .verified:
            let results = try await FoodSearchManager.shared.searchFoods(with: searchText, page: page)
            return results
        }
    }
    
    public var recentFoods: [Food] {
        Array(
            myFoods
                .sorted(by: { $0.updatedAt > $1.updatedAt })
                .prefix(5)
        )
    }
}

struct FoodSearchManager {
    
    struct Params: Codable {
        let string: String
        let page: Int
        let per: Int
    }
    
    struct FoodSearchResponse: Codable {
        struct Metadata: Codable {
            let total: Int
            let page: Int
            let per: Int
        }
        
        let items: [ServerPresetFood]
        let metadata: Metadata
        
        var haveMoreResults: Bool {
            /// This is how we can tell if there are more results as the `total` value is currently arbitrarily set a very high number
            /// (to allow for premature exiting of the search algorithm for better perf)
            items.count == metadata.page
        }
        
        var foods: [Food] {
            items
                .map { $0.food }
                .removingDuplicates()
        }
    }
    
    public static var shared = FoodSearchManager()
    
    var networkManager: NetworkManager {
        DataManager.shared.networkManager
    }
    
    func searchFoods(with searchText: String, page: Int) async throws -> (foods: [Food], haveMoreResults: Bool) {
        let params = Params(
            string: searchText,
            page: page,
            per: 25
        )
        
        let responseData = try await networkManager.post(params, to: .presetFoodsSearch)
        let string = String(data: responseData, encoding: .utf8)!
        let response: FoodSearchResponse
        do {
            response = try JSONDecoder().decode(FoodSearchResponse.self, from: responseData)
        } catch {
            print(error)
            throw FoodSearchError.jsonDecodeError(error.localizedDescription)
        }
        
        return (foods: response.foods, haveMoreResults: response.haveMoreResults)
    }
}

enum FoodSearchError: Error {
    case jsonDecodeError(String)
}

/// ** Keep this in sync with PrepServer.PresetFood **
struct ServerPresetFood: Codable {
    
    /// ** Keep this in sync with PrepServer.Barcode **
    struct ServerBarcode: Codable {
        var id: UUID
        var payload: String
        var symbology: BarcodeSymbology
    }
    
    var id: UUID
    var name: String
    var emoji: String
    var detail: String?
    var brand: String?
    var barcodes: [ServerBarcode]?

    var amount: FoodValue
    var serving: FoodValue?
    var nutrients: FoodNutrients
    var sizes: [FoodSize]
    var density: FoodDensity?

    var dataset: FoodDataset
    var datasetFoodId: String?

    var numberOfTimesConsumed: Int
    
    var updatedAt: Double
    
    var food: Food {
        var foodBarcodes: [FoodBarcode] {
            barcodes?.map { FoodBarcode(payload: $0.payload, symbology: $0.symbology) }
            ?? []
        }
        
        var convertedBarcodes: [Barcode] {
            barcodes?.map { Barcode(id: $0.id, payload: $0.payload, symbology: $0.symbology) }
            ?? []
        }

        return Food(
            id: id,
            type: .food,
            name: name,
            emoji: emoji,
            detail: detail,
            brand: brand,
            numberOfTimesConsumedGlobally: numberOfTimesConsumed,
            numberOfTimesConsumed: 0,
            lastUsedAt: nil,
            firstUsedAt: nil,
            info: .init(
                amount: amount,
                serving: serving,
                nutrients: nutrients,
                sizes: sizes,
                density: density,
                linkUrl: nil,
                prefilledUrl: nil,
                imageIds: nil,
                barcodes: foodBarcodes,
                spawnedUserFoodId: nil,
                spawnedPresetFoodId: nil
            ),
            publishStatus: nil,
            jsonSyncStatus: .synced,
            childrenFoods: nil,
            dataset: dataset,
            barcodes: convertedBarcodes,
            syncStatus: .synced,
            updatedAt: updatedAt,
            deletedAt: nil
        )
    }
}
