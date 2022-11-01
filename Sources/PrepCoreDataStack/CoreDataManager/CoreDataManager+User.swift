import CoreData
import PrepDataTypes

extension CoreDataManager {
    func userEntity() throws -> UserEntity? {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        return try viewContext.fetch(fetchRequest).first
    }
    
    func save(_ userEntity: UserEntity) throws {
        self.viewContext.insert(userEntity)
        try self.viewContext.save()
    }
    
    func markUserAsSynced(context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        let userEntity = try context.fetch(fetchRequest).first
        userEntity?.syncStatus = SyncStatus.synced.rawValue
    }
    
    func markDaysAsSynced(dayIds: [UUID], context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<DayEntity>(entityName: "DayEntity")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", dayIds)
        let dayEntities = try context.fetch(fetchRequest)
        for dayEntity in dayEntities {
            dayEntity.syncStatus = SyncStatus.synced.rawValue
        }
    }

    func markMealsAsSynced(mealIds: [UUID], context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", mealIds)
        let mealEntities = try context.fetch(fetchRequest)
        for mealEntity in mealEntities {
            mealEntity.syncStatus = SyncStatus.synced.rawValue
        }
    }

    func replaceUser(with newUserEntity: UserEntity, in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        guard let existingUser =  try context.fetch(request).first else {
            throw CoreDataManagerError.couldNotFindCurrentUser
        }
        
        if let existingId = existingUser.id, let newId = newUserEntity.id {
            if existingId != newId {
                print("Replacing userId with actual: \(newId)")
            }
        }

        context.delete(existingUser)
        try context.save()
    }
}

extension CoreDataManager {
    func updatedEntities(completion: ((UpdatedEntities) -> ())) {
        let bgContext = newBackgroundContext()
        do {
            try bgContext.performAndWait {
                
                /// Only fetch things that have an `updatedAt` later than `versionTimestamp`
                let userRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
                userRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                let userEntity = try bgContext.fetch(userRequest).first

                let daysRequest = NSFetchRequest<DayEntity>(entityName: "DayEntity")
                daysRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                let dayEntities = try bgContext.fetch(daysRequest)

                let mealsRequest = NSFetchRequest<MealEntity>(entityName: "MealEntity")
                mealsRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                let mealEntities = try bgContext.fetch(mealsRequest)

                let updatedEntites = UpdatedEntities(
                    userEntity: userEntity,
                    dayEntities: dayEntities,
                    mealEntities: mealEntities
                )
                
                completion(updatedEntites)
            }
        } catch {
            print("Error getting updatedEntities: \(error)")
        }
    }
}

struct UpdatedEntities {
    let userEntity: UserEntity?
    let dayEntities: [DayEntity]?
    let mealEntities: [MealEntity]?
}
