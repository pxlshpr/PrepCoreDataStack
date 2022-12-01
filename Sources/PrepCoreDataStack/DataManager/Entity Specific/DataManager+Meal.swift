import Foundation
import PrepDataTypes

//MARK: - Fetch
public extension DataManager {

    func existingMeal(matching dayMeal: DayMeal) throws -> Meal? {
        guard let mealEntity = try coreDataManager.mealEntity(
            with: dayMeal.id,
            context: coreDataManager.viewContext
        ) else { return nil }
        
        return Meal(from: mealEntity)
    }
    
    func fetchMealOrCreate(for dayMeal: DayMeal, on date: Date) throws -> Meal {
        guard let existingMeal = try existingMeal(matching: dayMeal) else {
            print("🍽 Creating meal")
            return try addNewMeal(
                named: dayMeal.name,
                at: Date(timeIntervalSince1970: dayMeal.time),
                on: date
            )
        }
        print("🍽 Returning existing meal")
        return existingMeal
    }
    
    func getMealsForDate(_ date: Date) async throws -> [Meal] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.mealEntities(for: date) { mealEntities in
                    let meals = mealEntities.map { Meal(from: $0) }
                    continuation.resume(returning: meals)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

//MARK: Create / Update / Delete
public extension DataManager {
    func addNewMeal(named name: String, at time: Date, on date: Date) throws -> Meal {
        guard let user else {
            throw DataManagerError.noUserFound
        }
        
        /// Pass the details to `CoreDataManager`, which would return the created `MealEntity`
        /// after creating and linking a newly created `DayEntity` if needed
        let mealEntity = try coreDataManager.createAndSaveMealEntity(
            named: name,
            at: time,
            on: date,
            for: user.id
        )

        /// Send a notification named`didAddMeal` with the new `Meal`
        let meal = Meal(from: mealEntity)
        
        NotificationCenter.default.post(
            name: .didAddMeal,
            object: nil,
            userInfo: [
                Notification.Keys.meal: meal
            ]
        )
        
        return meal
    }
    
    func deleteMeal(_ meal: DayMeal) throws {
        try coreDataManager.deleteMeal(meal)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            NotificationCenter.default.post(
                name: .didDeleteMeal,
                object: nil,
                userInfo: [
                    Notification.Keys.uuid: meal.id
                ]
            )
        }
    }
}
