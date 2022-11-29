import Foundation
import PrepDataTypes

//MARK: FoodItemEntity → FoodItem
public extension FoodItem {
    init(from entity: FoodItemEntity) {
        
        let food = Food(from: entity.food!)
        
        let meal: Meal?
        if let mealEntity = entity.meal {
            meal = Meal(from: mealEntity)
        } else {
            meal = nil
        }

        
        let parentFood: Food?
        if let parentFoodEntity = entity.parentFood {
            parentFood = Food(from: parentFoodEntity)
        } else {
            parentFood = nil
        }

        self.init(
            id: entity.id!,
            food: food,
            parentFood: parentFood,
            meal: meal,
            amount: try! JSONDecoder().decode(FoodValue.self, from: entity.amount!),
            markedAsEatenAt: entity.markedAsEatenAt,
            sortPosition: Int(entity.sortPosition),
            syncStatus: SyncStatus(rawValue: entity.syncStatus)!,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt
        )
    }
}
