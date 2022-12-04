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

extension FoodItemEntity {
    func update(
        amount: FoodValue,
        markedAsEatenAt: Double?,
        foodEntity: FoodEntity,
        mealEntity: MealEntity,
        sortPosition: Int,
        in context: NSManagedObjectContext
    ) throws {
//        guard let foodEntity = try foodEntity(with: mealFoodItem.food.id, context: viewContext) else {
//            throw CoreDataManagerError.missingFood
//        }
//
//        guard let mealEntity = try mealEntity(with: mealId, context: viewContext) else {
//            throw CoreDataManagerError.missingMeal
//        }
        
        let mealChanged = self.meal?.id != mealEntity.id

        self.food = foodEntity
        self.meal = mealEntity
        
        self.amount = try! JSONEncoder().encode(amount)
        self.markedAsEatenAt = markedAsEatenAt ?? 0
        self.sortPosition = Int16(sortPosition)
        
        self.syncStatus = SyncStatus.synced.rawValue
        self.updatedAt = Date().timeIntervalSince1970

        try context.save()
        
        if mealChanged {
            /// Send notifications for UI to handle the meal change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .didDeleteFoodItemFromMeal, object: nil, userInfo: [
                    Notification.Keys.uuid: self.id!
                ])
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let foodItem = FoodItem(from: self)
                    NotificationCenter.default.post(name: .didAddFoodItemToMeal, object: nil, userInfo: [
                        Notification.Keys.foodItem: foodItem
                    ])
//                }
            }
        }
    }
}
