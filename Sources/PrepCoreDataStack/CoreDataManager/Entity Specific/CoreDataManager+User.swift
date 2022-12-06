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
    func fetchGoalSetEntity(with id: UUID, context: NSManagedObjectContext? = nil) throws -> GoalSetEntity? {
        let context = context ?? viewContext
        let request = NSFetchRequest<GoalSetEntity>(entityName: "GoalSetEntity")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first
    }
}

//TODO: Create a generic version of these
extension CoreDataManager {
    func dayEntity(with id: String, context: NSManagedObjectContext) throws -> DayEntity? {
        let request = NSFetchRequest<DayEntity>(entityName: "DayEntity")
        request.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(request).first
    }
}

extension CoreDataManager {
    func mealEntity(with id: UUID, context: NSManagedObjectContext? = nil) throws -> MealEntity? {
        let context = context ?? viewContext
        let request = NSFetchRequest<MealEntity>(entityName: "MealEntity")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first
    }
    
    func hardDeleteMealEntity(with id: UUID, context: NSManagedObjectContext) throws {
        guard let mealEntity = try mealEntity(with: id, context: context) else {
            /// It's already been deleted
            return
        }
        /// This will cascade deletions to `FoodItem`s too
        context.delete(mealEntity)
        try context.save()
    }
}

extension CoreDataManager {
    func foodItemEntity(with id: UUID, context: NSManagedObjectContext? = nil) throws -> FoodItemEntity? {
        let context = context ?? self.viewContext
        let request = NSFetchRequest<FoodItemEntity>(entityName: "FoodItemEntity")
        request.predicate = NSPredicate(format: "id == %@", id.uuidString)
        return try context.fetch(request).first
    }
    
    func hardDeleteFoodItemEntity(with id: UUID, context: NSManagedObjectContext) throws {
        guard let entity = try foodItemEntity(with: id, context: context) else {
            /// It's already been deleted
            return
        }
        context.delete(entity)
        try context.save()
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
    func foodItemEntities(with syncStatus: SyncStatus) -> [FoodItemEntity] {
        do {
            let request = NSFetchRequest<FoodItemEntity>(entityName: "FoodItemEntity")
            request.predicate = NSPredicate(format: "syncStatus == %d", syncStatus.rawValue)
            return try viewContext.fetch(request)
        } catch {
            fatalError("Fetch error with notSyncedFoodItemEntities: \(error)")
        }
    }
    
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
                
                let foodItemsRequest = NSFetchRequest<FoodItemEntity>(entityName: "FoodItemEntity")
                foodItemsRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                let foodItemEntities = try bgContext.fetch(foodItemsRequest)

                let goalSetsRequest = NSFetchRequest<GoalSetEntity>(entityName: "GoalSetEntity")
                goalSetsRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                let goalSetEntities = try bgContext.fetch(goalSetsRequest)

                let updatedEntites = UpdatedEntities(
                    userEntity: userEntity,
                    dayEntities: dayEntities,
                    mealEntities: mealEntities,
                    foodEntities: foodEntities,
                    foodItemEntities: foodItemEntities,
                    goalSetEntities: goalSetEntities
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
    let foodItemEntities: [FoodItemEntity]?
    let goalSetEntities: [GoalSetEntity]?
}
