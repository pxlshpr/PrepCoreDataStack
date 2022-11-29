import Foundation
import PrepDataTypes

enum DataManagerError: Error {
    case noUserFound
    case noDayFoundWhenInsertingMealFromServer
}

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
    
    func getDay(for date: Date) async throws -> Day? {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.dayEntity(for: date) { dayEntity in
                    guard let dayEntity else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let day = Day(from: dayEntity)
                    continuation.resume(returning: day)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func days(for range: Range<Date>) async throws -> [Day] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.dayEntities(for: range) { dayEntities in
                    let days = dayEntities.map { Day(from: $0) }
                    continuation.resume(returning: days)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

//TODO: Move this to DataManager+FoodItem
public extension DataManager {
    
    func addNewMealItem(_ mealFoodItem: MealFoodItem, to meal: Meal) throws -> FoodItem {
        guard let user else { throw DataManagerError.noUserFound }
        
        var mealFoodItem = mealFoodItem
        mealFoodItem.sortPosition = meal.nextSortPosition
        
        let foodItemEntity = try coreDataManager.createAndSaveMealItem(
            mealFoodItem,
            to: meal,
            for: user.id
        )
        
        let foodItem = FoodItem(from: foodItemEntity)

        NotificationCenter.default.post(
            name: .didAddFoodItemToMeal,
            object: nil,
            userInfo: [
                Notification.Keys.foodItem: foodItem
            ]
        )
        
        return foodItem
    }
}

extension Meal {
    var nextSortPosition: Int {
        let sorted = foodItems.sorted(by: { $0.sortPosition > $1.sortPosition })
        guard let first = sorted.first else { return 1 }
        return first.sortPosition + 1
    }
}
