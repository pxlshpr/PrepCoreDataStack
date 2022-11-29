import Foundation
import PrepDataTypes

extension CoreDataManager {
 
    /// Returns a newly created `MealEntity` after creating and linking a newly created `DayEntity` if needed
    func createAndSaveMealEntity(named name: String, at time: Date, on date: Date, for userId: UUID) throws -> MealEntity {
        let dayEntity = try fetchOrCreateDayEntity(on: date, for: userId)
        let mealEntity = MealEntity(
            context: viewContext,
            name: name,
            time: time,
            dayEntity: dayEntity
        )
        self.viewContext.insert(mealEntity)
        try self.viewContext.save()
        return mealEntity
    }
    
    func mealEntities(for date: Date, completion: @escaping (([MealEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    guard let day = try self.fetchDayEntity(for: date, context: bgContext) else {
                        completion([])
                        return
                    }
                    let meals = day.meals?.allObjects as? [MealEntity] ?? []
                    completion(meals)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }    
}

//TODO: Move this to CoreDataManager+FoodItem

extension CoreDataManager {

    /// Returns a newly created `FoodItemEntity` after creating and linking an existing `Meal`
    func createAndSaveMealItem(_ mealFoodItem: MealFoodItem, to meal: Meal, for userId: UUID) throws -> FoodItemEntity {
        
        guard let foodEntity = try foodEntity(with: mealFoodItem.food.id, context: viewContext) else {
            throw CoreDataManagerError.missingDay
        }
        
        guard let mealEntity = try mealEntity(with: meal.id, context: viewContext) else {
            throw CoreDataManagerError.missingDay
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
}
