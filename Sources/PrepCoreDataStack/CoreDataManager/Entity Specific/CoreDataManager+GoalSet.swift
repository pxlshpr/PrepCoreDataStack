import Foundation
import CoreData
import PrepDataTypes

extension CoreDataManager {
    func insertGoalSetEntity(_ entity: GoalSetEntity) {
        viewContext.insert(entity)
    }
}

extension CoreDataManager {
    func fetchGoalSetEntities(context: NSManagedObjectContext) throws -> [GoalSetEntity] {
        let request: NSFetchRequest<GoalSetEntity> = GoalSetEntity.fetchRequest()
        return try context.fetch(request)
    }
}
extension CoreDataManager {
    func goalSetEntities(completion: @escaping (([GoalSetEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {
                do {
                    let entities = try self.fetchGoalSetEntities(context: bgContext)
                    completion(entities)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }
}

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
