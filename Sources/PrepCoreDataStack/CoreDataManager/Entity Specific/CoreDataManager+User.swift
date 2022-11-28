import CoreData
import PrepDataTypes

//MARK: **** CLEAN THESE *****

extension CoreDataManager {
    func userEntity(context: NSManagedObjectContext) throws -> UserEntity? {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        return try context.fetch(fetchRequest).first
    }
    
    func insertUserEntity(_ userEntity: UserEntity) throws {
        self.viewContext.insert(userEntity)
        try self.viewContext.save()
    }

    func markUserAsSynced(context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        let userEntity = try context.fetch(fetchRequest).first
        userEntity?.syncStatus = SyncStatus.synced.rawValue
    }
    
    func markDaysAsSynced(dayIds: [String], context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<DayEntity>(entityName: "DayEntity")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", dayIds)
        let dayEntities = try context.fetch(fetchRequest)
        for dayEntity in dayEntities {
            dayEntity.syncStatus = SyncStatus.synced.rawValue
        }
    }

    func markFoodsAsSynced(ids: [UUID], context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<FoodEntity>(entityName: "FoodEntity")
        fetchRequest.predicate = NSPredicate(format: "id IN %@", ids)
        let foodEntities = try context.fetch(fetchRequest)
        for foodEntity in foodEntities {
            foodEntity.syncStatus = SyncStatus.synced.rawValue
        }
    }

    func markImagesAsSynced(ids: [UUID], context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let imageFileEntities = try context.fetch(request)
        for imageFileEntity in imageFileEntities {
            imageFileEntity.syncStatus = SyncStatus.synced.rawValue
        }
    }

    func markJSONsAsSynced(ids: [UUID], context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<JSONFileEntity>(entityName: "JSONFileEntity")
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let entities = try context.fetch(request)
        for entity in entities {
            entity.syncStatus = SyncStatus.synced.rawValue
        }
    }

    func markImagesAsSyncing(ids: [UUID], context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let imageFileEntities = try context.fetch(request)
        for imageFileEntity in imageFileEntities {
            imageFileEntity.syncStatus = SyncStatus.syncing.rawValue
        }
    }

    func markJSONsAsSyncing(ids: [UUID], context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<JSONFileEntity>(entityName: "JSONFileEntity")
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let entities = try context.fetch(request)
        for entity in entities {
            entity.syncStatus = SyncStatus.syncing.rawValue
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
    
    //MARK: - Cleaned
    
    func setSyncStatus<T: Syncable>(
        for entity: T.Type,
        with ids: [UUID],
        to syncStatus: SyncStatus,
        in context: NSManagedObjectContext
    ) throws {
        let entityName = String(describing: entity)
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let entities = try context.fetch(request)
        for entity in entities {
            entity.syncStatus = syncStatus.rawValue
        }
    }

}

extension CoreDataManager {
    func goalSetEntity(with id: String, context: NSManagedObjectContext) throws -> GoalSetEntity? {
        let request = NSFetchRequest<GoalSetEntity>(entityName: "GoalSetEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first
    }
}

extension CoreDataManager {
    func dayEntity(with id: String, context: NSManagedObjectContext) throws -> DayEntity? {
        let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first
    }
}

extension CoreDataManager {
    func mealEntity(with id: UUID, context: NSManagedObjectContext) throws -> MealEntity? {
        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first
    }
}

extension CoreDataManager {
    func foodEntity(with id: UUID, context: NSManagedObjectContext) throws -> FoodEntity? {
        let request = NSFetchRequest<FoodEntity>(entityName: "FoodEntity")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first
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

                let foodsRequest = NSFetchRequest<FoodEntity>(entityName: "FoodEntity")
                foodsRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                let foodEntities = try bgContext.fetch(foodsRequest)

                let updatedEntites = UpdatedEntities(
                    userEntity: userEntity,
                    dayEntities: dayEntities,
                    mealEntities: mealEntities,
                    foodEntities: foodEntities
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
    let foodEntities: [FoodEntity]?
}
