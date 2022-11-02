import Foundation
import PrepDataTypes

enum DataManagerError: Error {
    case noUserFound
    case noDayFound
}

public extension DataManager {

    func addNewMeal(named name: String, at time: Date, on date: Date) throws {
        guard let user else {
            throw DataManagerError.noUserFound
        }
        
        //TODO: We need to know what the current day is, assuming it to be today for now
        /// Construct the new `Meal`
        /// Pass this to CoreData manager as a `MealEntity`, which would create the `DayEntity` if needed
        let mealEntity = try coreDataManager.saveMealEntity(named: name, at: time, on: date, for: user.id)

        /// Now send a notification named`didAddMeal` with the new `Meal` as a user info
        /// The `ListPage` and `TimelinePage` should subscribe to notifications of this
        /// Once received, they should get the `Meal` and see if it matches `Date` it is displaying
        /// If it matches—it should then insert the `Meal` into the correct position with an animation
        let meal = Meal(from: mealEntity)
        NotificationCenter.default.post(
            name: .didAddMeal,
            object: nil,
            userInfo: [
                Notification.Keys.meal: meal
            ]
        )

        /// Now handle the Syncer to send, and receive on both the device and the server
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
