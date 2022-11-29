import Foundation
import PrepDataTypes
import CoreData

//MARK: FoodItem → FoodItemEntity
extension FoodItemEntity {
    convenience init(
        context: NSManagedObjectContext,
        foodItem: FoodItem,
        foodEntity: FoodEntity,
        parentFoodEntity: FoodEntity? = nil,
        mealEntity: MealEntity? = nil
    ) {
        self.init(context: context)
        
        self.id = foodItem.id
        
        self.food = foodEntity
        self.parentFood = parentFoodEntity
        self.meal = mealEntity
        
        self.amount = try! JSONEncoder().encode(foodItem.amount)
        self.markedAsEatenAt = foodItem.markedAsEatenAt ?? 0
        self.sortPosition = Int16(foodItem.sortPosition)
        self.syncStatus = Int16(foodItem.syncStatus.rawValue)
        self.updatedAt = foodItem.updatedAt
        self.deletedAt = foodItem.deletedAt ?? 0
    }
}

//MARK: MealFoodItem → FoodItemEntity
extension FoodItemEntity {
    convenience init(
        context: NSManagedObjectContext,
        mealFoodItem: MealFoodItem,
        foodEntity: FoodEntity,
        mealEntity: MealEntity
    ) {
        self.init(context: context)
        
        
        self.id = mealFoodItem.id
        
        self.food = foodEntity
        self.parentFood = nil
        self.meal = mealEntity
        
        self.amount = try! JSONEncoder().encode(mealFoodItem.amount)
        self.markedAsEatenAt = mealFoodItem.markedAsEatenAt ?? 0
        self.sortPosition = Int16(mealFoodItem.sortPosition)
        self.syncStatus = SyncStatus.notSynced.rawValue
        self.updatedAt = Date().timeIntervalSince1970
        self.deletedAt = 0
    }
}
