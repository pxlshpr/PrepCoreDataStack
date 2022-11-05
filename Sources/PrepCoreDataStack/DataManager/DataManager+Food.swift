import Foundation
import PrepDataTypes
import PrepFoodForm

public extension DataManager {
    func addNewFood(_ userFood: UserFood) throws {
        guard let user else {
            throw DataManagerError.noUserFound
        }
        
        /// Construct the new `Food`
        /// Pass this to `CoreDataManager` as a `FoodEntity`
    }
}
