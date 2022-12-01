import Foundation
import PrepDataTypes

public extension DataManager {
    
    func deleteMealItem(_ mealFoodItem: MealFoodItem) throws {
        try coreDataManager.deleteMealItem(mealFoodItem)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didDeleteFoodItemFromMeal,
                object: nil,
                userInfo: [
                    Notification.Keys.uuid: mealFoodItem.id
                ]
            )
        }
    }
    
    func addNewMealItem(_ mealFoodItem: MealFoodItem, to meal: Meal) throws {
        guard let user else { throw DataManagerError.noUserFound }
        
        var mealFoodItem = mealFoodItem
        mealFoodItem.sortPosition = meal.nextSortPosition
        
        let foodItemEntity = try coreDataManager.createAndSaveMealItem(
            mealFoodItem,
            to: meal,
            for: user.id
        )
        
        let foodItem = FoodItem(from: foodItemEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didAddFoodItemToMeal,
                object: nil,
                userInfo: [
                    Notification.Keys.foodItem: foodItem
                ]
            )
        }
    }
    
    func updateMealItem(_ mealFoodItem: MealFoodItem, with meal: Meal) throws {
        
        let updatedFoodItemEntity = try coreDataManager.updateMealItem(
            mealFoodItem,
            with: meal
        )
        
        let updatedFoodItem = FoodItem(from: updatedFoodItemEntity)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didUpdateMealFoodItem,
                object: nil,
                userInfo: [
                    Notification.Keys.foodItem: updatedFoodItem
                ]
            )
        }
    }
}
