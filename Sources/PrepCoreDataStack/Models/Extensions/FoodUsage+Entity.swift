import Foundation
import PrepDataTypes

//MARK: FoodUsageEntity → FoodUsage
public extension FoodUsage {
    init(from entity: FoodUsageEntity) {
        
        let food = Food(from: entity.food!)

        self.init(
            id: entity.id!,
            numberOfTimesConsumed: Int(entity.numberOfTimesConsumed),
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            food: food
        )
    }
}
