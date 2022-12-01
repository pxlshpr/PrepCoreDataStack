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
    
    /// Deletes meal from a `DayMeal` and returns the `Day` it belonged to so that we can manually remove it from the UI
    func deleteMeal(_ meal: DayMeal) throws {
        guard let meal = try mealEntity(with: meal.id, context: viewContext)
        else {
            throw CoreDataManagerError.missingMeal
        }
        
        self.viewContext.delete(meal)
        try self.viewContext.save()
    }
}
