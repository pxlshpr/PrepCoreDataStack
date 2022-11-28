import Foundation
import PrepDataTypes

enum DataManagerError: Error {
    case noUserFound
    case noDayFoundWhenInsertingMealFromServer
}

public extension DataManager {
    func setGoalSet(_ goalSet: GoalSet, on date: Date) throws {
        guard let user else { throw DataManagerError.noUserFound }
        try coreDataManager.setGoalSet(goalSet, on: date, for: user.id)
    }
}

public extension DataManager {

    func addNewMeal(named name: String, at time: Date, on date: Date) throws {
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
