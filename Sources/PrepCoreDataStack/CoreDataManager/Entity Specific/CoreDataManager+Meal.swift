import Foundation
import PrepDataTypes
import CoreData

extension CoreDataManager {
 
    
    /// Returns a newly created `MealEntity` after creating and linking a newly created `DayEntity` if needed
    func createAndSaveMealEntity(
        named name: String,
        at time: Date,
        on date: Date,
        with goalSet: GoalSet?,
        for userId: UUID
    ) throws -> MealEntity {
        
        let goalSetEntity: GoalSetEntity?
        if let goalSet {
            guard let entity = try fetchGoalSetEntity(with: goalSet.id, context: viewContext) else {
                throw CoreDataManagerError.missingGoalSetEntity
            }
            goalSetEntity = entity
        } else {
            goalSetEntity = nil
        }
        
        let dayEntity = try fetchOrCreateDayEntity(on: date, for: userId)
        
        let mealEntity = MealEntity(
            context: viewContext,
            name: name,
            time: time,
            dayEntity: dayEntity,
            goalSetEntity: goalSetEntity
        )
        self.viewContext.insert(mealEntity)
        try self.viewContext.save()
        return mealEntity
    }
    
    func updateMealEntity(
        withId id: UUID,
        name: String,
        time: Date,
        goalSet: GoalSet?
    ) throws -> MealEntity {
        
        guard let mealEntity = try mealEntity(with: id) else {
            throw DataManagerError.mealNotFound
        }
        
        let goalSetEntity: GoalSetEntity?
        if let goalSet {
            guard let entity = try fetchGoalSetEntity(with: goalSet.id, context: viewContext) else {
                throw CoreDataManagerError.missingGoalSetEntity
            }
            goalSetEntity = entity
        } else {
            goalSetEntity = nil
        }
        
        mealEntity.name = name
        mealEntity.time = time.timeIntervalSince1970
        mealEntity.goalSet = goalSetEntity
        
        mealEntity.syncStatus = Int16(SyncStatus.notSynced.rawValue)
        mealEntity.updatedAt = Date().timeIntervalSince1970

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
                    completion(day.mealEntities)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }
    
    /// Soft Deletes a meal by setting its `deletedAt` timestamp and queuing it for a sync
    /// We're not soft-deleting the `FoodItem`s here as they won't appear in the UI any longer
    /// (since they're not part of a visible meal), and the eventual hard-delete of the meal
    /// (after the object is synced) will cascade the hard-deletion of those
    func softDeleteMeal(_ meal: DayMeal) throws {
        guard let mealEntity = try mealEntity(with: meal.id, context: viewContext)
        else {
            throw CoreDataManagerError.missingMeal
        }
        
        mealEntity.deletedAt = Date().timeIntervalSince1970
        mealEntity.syncStatus = Int16(SyncStatus.notSynced.rawValue)
        
        try self.viewContext.save()
    }
}

extension CoreDataManager {
    func latestMealBeforeNow() throws -> MealEntity? {
        try latestMealBefore(Date())
//        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
//        request.predicate = NSPredicate(
//            format: "time < %f AND deletedAt == 0", Date().timeIntervalSince1970
//        )
//        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \MealEntity.time, ascending: false),
//        ]
//        return try viewContext.fetch(request).first
    }
    
    func earliestMealAfterNow() throws -> MealEntity? {
        try earliestMealAfter(Date())
//        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
//        request.predicate = NSPredicate(
//            format: "time > %f AND deletedAt == 0", Date().timeIntervalSince1970
//        )
//        request.sortDescriptors = [
//            NSSortDescriptor(keyPath: \MealEntity.time, ascending: true),
//        ]
//        return try viewContext.fetch(request).first
    }

    func getLatestMeal(before time: Date, completion: @escaping ((MealEntity?) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    guard let meal = try self.latestMealBefore(time, context: bgContext) else {
                        completion(nil)
                        return
                    }
                    completion(meal)
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    func getNextMeal(after time: Date, completion: @escaping ((MealEntity?) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    guard let meal = try self.earliestMealAfter(time, context: bgContext) else {
                        completion(nil)
                        return
                    }
                    completion(meal)
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    func getMealsWithTime(on date: Date, completion: @escaping (([MealEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    let meals = try self.mealsWithTime(on: date, context: bgContext)
                    completion(meals)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }

    func mealsWithTime(on date: Date, context: NSManagedObjectContext? = nil) throws -> [MealEntity] {
        let context = context ?? viewContext
        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        request.predicate = NSPredicate(
//            format: "(time < %f) AND (ANY foodItems.markedAsEatenAt > 0)", Date().timeIntervalSince1970
            format: "time > %f AND time < %f AND deletedAt == 0",
            date.startOfDay.timeIntervalSince1970,
            date.endOfDay.timeIntervalSince1970
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \MealEntity.time, ascending: true),
        ]
        return try context.fetch(request)
    }

    
    func earliestMealAfter(_ time: Date, context: NSManagedObjectContext? = nil) throws -> MealEntity? {
        let context = context ?? viewContext
        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        request.predicate = NSPredicate(
            format: "time > %f AND deletedAt == 0", time.timeIntervalSince1970
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \MealEntity.time, ascending: true),
        ]
        return try context.fetch(request).first
    }

    
    func latestMealBefore(_ time: Date, context: NSManagedObjectContext? = nil) throws -> MealEntity? {
        let context = context ?? viewContext
        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        request.predicate = NSPredicate(
//            format: "(time < %f) AND (ANY foodItems.markedAsEatenAt > 0)", Date().timeIntervalSince1970
            format: "time < %f AND deletedAt == 0", time.timeIntervalSince1970 - 60
        )
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \MealEntity.time, ascending: false),
        ]
        return try context.fetch(request).first
    }

}
