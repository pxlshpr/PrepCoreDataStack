import Foundation
import PrepDataTypes

public extension DataManager {
    
    func deleteMealItem(_ mealFoodItem: MealFoodItem, in dayMeal: DayMeal) throws {
        try coreDataManager.softDeleteMealItem(mealFoodItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didDeleteFoodItemFromMeal,
                object: nil,
                userInfo: [
                    Notification.Keys.uuid: mealFoodItem.id,
                    Notification.Keys.mealId: dayMeal.id
                ]
            )
        }
    }
    
    func addNewMealItem(_ mealFoodItem: MealFoodItem, to meal: Meal) throws {
        var mealFoodItem = mealFoodItem
        mealFoodItem.sortPosition = meal.nextSortPosition
        
        let foodItemEntity = try coreDataManager.createAndSaveMealItem(
            mealFoodItem,
            toMealWithId: meal.id
        )
        
        let foodItem = FoodItem(from: foodItemEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didAddFoodItemToMeal,
                object: nil,
                userInfo: [
                    Notification.Keys.foodItem: foodItem,
                    Notification.Keys.mealId: meal.id
                ]
            )
        }
    }
    
    func toggleCompletion(for mealFoodItem: MealFoodItem) throws {
        let updatedFoodItemEntity = try coreDataManager.toggleCompletion(
            for: mealFoodItem
        )
        
        let updatedFoodItem = FoodItem(from: updatedFoodItemEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didUpdateMealFoodItem,
                object: nil,
                userInfo: [
                    Notification.Keys.foodItem: updatedFoodItem,
                    Notification.Keys.mealId: updatedFoodItemEntity.meal!.id!
                ]
            )
        }
    }
    
    func updateMealItem(
        _ mealFoodItem: MealFoodItem,
        dayMeal: DayMeal,
        sortPosition: Int? = nil
    ) throws {
        
        let sortPosition = sortPosition ?? mealFoodItem.sortPosition
        
        let updatedFoodItemEntity = try coreDataManager.updateMealItem(
            mealFoodItem,
            mealId: dayMeal.id,
            sortPosition: sortPosition
        )
        
        let updatedFoodItem = FoodItem(from: updatedFoodItemEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didUpdateMealFoodItem,
                object: nil,
                userInfo: [
                    Notification.Keys.foodItem: updatedFoodItem,
                    Notification.Keys.mealId: dayMeal.id
                ]
            )
        }
    }
    
    func numberOfFoodItems(with syncStatus: SyncStatus) -> Int {
        coreDataManager.foodItemEntities(with: syncStatus).count
    }

    func silentlyUpdateSortPosition(for mealFoodItem: MealFoodItem) throws {
        try coreDataManager.updateSortPosition(for: mealFoodItem)
    }
    
    func moveMealItem(
        _ mealFoodItem: MealFoodItem,
        to dayMeal: DayMeal,
        after foodItemToPlaceAfter: MealFoodItem?
    ) throws {
        
        /// Either place it after what was specified or the start
        let sortPosition: Int
        if let foodItemToPlaceAfter {
            sortPosition = foodItemToPlaceAfter.sortPosition + 1
        } else {
            sortPosition = 1
        }
        try updateMealItem(mealFoodItem, dayMeal: dayMeal, sortPosition: sortPosition)
    }

    func duplicateMealItem(
        _ mealFoodItem: MealFoodItem,
        to dayMeal: DayMeal,
        after foodItemToPlaceAfter: MealFoodItem?
    ) throws {

        /// Either place it after what was specified or the start
        let sortPosition: Int
        if let foodItemToPlaceAfter {
            sortPosition = foodItemToPlaceAfter.sortPosition + 1
        } else {
            sortPosition = 1
        }
        
        var mealFoodItem = mealFoodItem
        mealFoodItem.id = UUID()
        mealFoodItem.sortPosition = sortPosition
        
        let foodItemEntity = try coreDataManager.createAndSaveMealItem(
            mealFoodItem,
            toMealWithId: dayMeal.id
        )
        
        let foodItem = FoodItem(from: foodItemEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didAddFoodItemToMeal,
                object: nil,
                userInfo: [
                    Notification.Keys.foodItem: foodItem,
                    Notification.Keys.mealId: dayMeal.id
                ]
            )
        }
    }


}
