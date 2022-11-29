import Foundation
import PrepDataTypes

extension CoreDataManager {
    func setGoalSet(_ goalSet: GoalSet, on date: Date, for userId: UUID) throws {
        let dayEntity = try fetchOrCreateDayEntity(on: date, for: userId)
        
        /// Fetch `GoalSetEntity` with `id`
        guard let goalSetEntity = try goalSetEntity(with: goalSet.id.uuidString, context: viewContext) else {
            throw CoreDataManagerError.missingGoalSetEntity
        }
        
        /// Assign `GoalSet` to `Day` as `diet`
        dayEntity.diet = goalSetEntity
        
        /// Reset the `syncStatus` and `updatedAt` fields so that the `SyncManager` syncs it in the next poll
        dayEntity.syncStatus = SyncStatus.notSynced.rawValue
        dayEntity.updatedAt = Date().timeIntervalSince1970
        try self.viewContext.save()
    }
    
    func removeGoalSet(on date: Date) throws {
        guard let dayEntity = try fetchDayEntity(for: date, context: viewContext) else {
            throw CoreDataManagerError.missingDay
        }
        
        dayEntity.diet = nil

        /// Reset the `syncStatus` and `updatedAt` fields so that the `SyncManager` syncs it in the next poll
        dayEntity.syncStatus = SyncStatus.notSynced.rawValue
        dayEntity.updatedAt = Date().timeIntervalSince1970
        try self.viewContext.save()
    }
}
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
