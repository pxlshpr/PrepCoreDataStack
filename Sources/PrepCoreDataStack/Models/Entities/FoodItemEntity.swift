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
    func toggleCompletion(in context: NSManagedObjectContext) throws {
        if markedAsEatenAt == 0 {
            self.markedAsEatenAt = Date().timeIntervalSince1970
        } else {
            self.markedAsEatenAt = 0
        }
        self.syncStatus = Int16(SyncStatus.notSynced.rawValue)
        self.updatedAt = Date().timeIntervalSince1970
        try context.save()
    }
    
    func update(
        amount: FoodValue,
        markedAsEatenAt: Double?,
        foodEntity: FoodEntity,
        mealEntity: MealEntity,
        sortPosition: Int,
        syncStatus: SyncStatus,
        updatedAt: Double = Date().timeIntervalSince1970,
        deletedAt: Double? = 0,
        postNotifications: Bool,
        in context: NSManagedObjectContext
    ) throws {
        let mealChanged = self.meal?.id != mealEntity.id

        self.food = foodEntity
        self.meal = mealEntity
        
        self.amount = try! JSONEncoder().encode(amount)
        self.markedAsEatenAt = markedAsEatenAt ?? 0
        self.sortPosition = Int16(sortPosition)
        
        self.syncStatus = syncStatus.rawValue
        
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt ?? 0

        //TODO: Look into this being a double save when called from SyncFrom processing (we already have one there at the end of the func)
        try context.save()

        /// Put this aside in case we're calling this with a background context
        /// in which case the id (and possibly the rest of the entity) becomes nil
        let foodItem = FoodItem(from: self)

        if mealChanged, postNotifications {
            /// Send notifications for UI to handle the meal change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .didDeleteFoodItemFromMeal, object: nil, userInfo: [
                    Notification.Keys.uuid: foodItem.id,
                    Notification.Keys.mealId: self.meal!.id!
                ])
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .didAddFoodItemToMeal, object: nil, userInfo: [
                        Notification.Keys.foodItem: foodItem,
                        Notification.Keys.mealId: self.meal!.id!
                    ])
//                }
            }
        }
    }
}
