import Foundation
import PrepDataTypes

extension CoreDataManager {

    /// Returns a newly created `FoodItemEntity` after creating and linking an existing `Meal`
    func createAndSaveMealItem(_ mealFoodItem: MealFoodItem, toMealWithId mealId: UUID) throws -> FoodItemEntity {
        
        guard let foodEntity = try foodEntity(with: mealFoodItem.food.id, context: viewContext) else {
            throw CoreDataManagerError.missingFood
        }
        
        guard let mealEntity = try mealEntity(with: mealId, context: viewContext) else {
            throw CoreDataManagerError.missingMeal
        }
        
        //TODO: Submit sortPosition here after incrementing it
        let foodItemEntity = FoodItemEntity(
            context: viewContext,
            mealFoodItem: mealFoodItem,
            foodEntity: foodEntity,
            mealEntity: mealEntity
        )
        
        self.viewContext.insert(foodItemEntity)
        try self.viewContext.save()
        return foodItemEntity
    }
    
    func updateMealItem(
        _ mealFoodItem: MealFoodItem,
        mealId: UUID,
        sortPosition: Int
    ) throws -> FoodItemEntity {
        
        guard let foodItemEntity = try foodItemEntity(with: mealFoodItem.id, context: viewContext) else {
            throw CoreDataManagerError.missingFoodItem
        }
        
        guard let foodEntity = try foodEntity(with: mealFoodItem.food.id, context: viewContext) else {
            throw CoreDataManagerError.missingFood
        }
        
        guard let mealEntity = try mealEntity(with: mealId, context: viewContext) else {
            throw CoreDataManagerError.missingMeal
        }
        
        let mealChanged = foodItemEntity.meal?.id != mealEntity.id

        foodItemEntity.food = foodEntity
        foodItemEntity.meal = mealEntity
        
        foodItemEntity.amount = try! JSONEncoder().encode(mealFoodItem.amount)
        foodItemEntity.markedAsEatenAt = mealFoodItem.markedAsEatenAt ?? 0
        foodItemEntity.sortPosition = Int16(sortPosition)
        
        foodItemEntity.syncStatus = SyncStatus.notSynced.rawValue
        foodItemEntity.updatedAt = Date().timeIntervalSince1970

        try self.viewContext.save()
        
        if mealChanged {
            /// Send notifications for UI to handle the meal change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .didDeleteFoodItemFromMeal, object: nil, userInfo: [
                    Notification.Keys.uuid: mealFoodItem.id
                ])
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    let foodItem = FoodItem(from: foodItemEntity)
                    NotificationCenter.default.post(name: .didAddFoodItemToMeal, object: nil, userInfo: [
                        Notification.Keys.foodItem: foodItem
                    ])
//                }
            }
        }
        
        return foodItemEntity
    }
        
    func updateSortPosition(for mealFoodItem: MealFoodItem) throws {
        
        guard let foodItemEntity = try foodItemEntity(with: mealFoodItem.id, context: viewContext) else {
            throw CoreDataManagerError.missingFoodItem
        }
        
        foodItemEntity.sortPosition = Int16(mealFoodItem.sortPosition)
        foodItemEntity.syncStatus = SyncStatus.notSynced.rawValue
        foodItemEntity.updatedAt = Date().timeIntervalSince1970
        try self.viewContext.save()
    }
    
    func deleteMealItem(_ mealFoodItem: MealFoodItem) throws {
        guard let foodItemEntity = try foodItemEntity(with: mealFoodItem.id, context: viewContext) else {
            throw CoreDataManagerError.missingFoodItem
        }
        
        self.viewContext.delete(foodItemEntity)
        try self.viewContext.save()
    }
}
