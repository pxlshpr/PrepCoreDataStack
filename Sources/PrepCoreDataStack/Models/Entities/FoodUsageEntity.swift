import Foundation
import PrepDataTypes
import CoreData

//MARK: FoodUsage → FoodUsageEntity
extension FoodUsageEntity {
    convenience init(
        context: NSManagedObjectContext,
        foodUsage: FoodUsage,
        foodEntity: FoodEntity
    ) {
        self.init(context: context)
        self.id = foodUsage.id
        self.numberOfTimesConsumed = Int32(foodUsage.numberOfTimesConsumed)
        self.createdAt = foodUsage.createdAt
        self.updatedAt = foodUsage.updatedAt
        self.food = foodEntity
    }
}

extension FoodUsageEntity {
    func update(with foodUsage: FoodUsage, in context: NSManagedObjectContext) throws {
        numberOfTimesConsumed = Int32(foodUsage.numberOfTimesConsumed)
        createdAt = foodUsage.createdAt
        updatedAt = foodUsage.updatedAt
    }
}
