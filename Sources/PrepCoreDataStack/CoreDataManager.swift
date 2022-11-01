import CoreData

class CoreDataManager: NSPersistentContainer {
 
    init() {
        guard
            let objectModelURL = Bundle.module.url(forResource: "Prep", withExtension: "momd"),
            let objectModel = NSManagedObjectModel(contentsOf: objectModelURL)
        else {
            fatalError("Failed to retrieve the object model")
        }
        super.init(name: "Prep", managedObjectModel: objectModel)
        self.initialize()
    }
    
    private func initialize() {
        self.loadPersistentStores { description, error in
            if let err = error {
                fatalError("Failed to load CoreData: \(err)")
            }
            print("Core data loaded: \(description)")
        }
    }
    
    func recentUserFoods() throws -> [UserFoodEntity] {
        var recents: [UserFoodEntity] = []
        try viewContext.performAndWait {
            let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
            let entities = try viewContext.fetch(fetchRequest)
            recents = entities
        }
        return recents
    }

    func _recentUserFoods() async throws -> [UserFoodEntity] {
        let bgContext = newBackgroundContext()
        var recents: [UserFoodEntity] = []
        try bgContext.performAndWait {
            let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
            let entities = try bgContext.fetch(fetchRequest)
            recents = entities
        }
        return recents
    }
    
    //MARK: UserFood
//    func userFoods() async throws -> [UserFoodEntity] {
//        let entities = try await performBackgroundTask { backgroundContext in
//            let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
//            let entities = try backgroundContext.fetch(fetchRequest)
//            return entities
//        }
//        return entities
//    }
//
    func saveUserFood(entity: UserFoodEntity, context: NSManagedObjectContext) throws {
        context.insert(entity)
        try context.save()
    }
//
//    func userFoodsToSync() async throws -> [UserFoodEntity] {
//        let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
//        fetchRequest.predicate = NSPredicate(format: "syncStatus != %d", SyncStatus.synced.rawValue)
//
//        return try await performBackgroundTask { backgroundContext in
//            return try backgroundContext.fetch(fetchRequest)
//        }
//    }
//
//    func userFoodsWithJsonToSync() async throws -> [UserFoodEntity] {
//        let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
//        fetchRequest.predicate = NSPredicate(format: "jsonSyncStatus != %d", SyncStatus.synced.rawValue)
//
//        return try await performBackgroundTask { backgroundContext in
//            return try backgroundContext.fetch(fetchRequest)
//        }
//    }
//
//    //MARK: ImageFile
//    func imageFiles() throws -> [ImageFileEntity] {
//        let fetchRequest = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
//        return try self.viewContext.fetch(fetchRequest)
//    }
//
//    func saveImageFile(entity: ImageFileEntity) throws {
//        self.viewContext.insert(entity)
//        try self.viewContext.save()
//    }
//
//    func imageFilesToSync() async throws -> [ImageFileEntity] {
//        let fetchRequest = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
//        fetchRequest.predicate = NSPredicate(format: "syncStatus != %d", SyncStatus.synced.rawValue)
//        return try await performBackgroundTask { backgroundContext in
//            return try backgroundContext.fetch(fetchRequest)
//        }
//    }
//
//    func changeSyncStatus(ofUserFoods userFoods: [UserFood], to syncStatus: SyncStatus) throws {
//
//        let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
//        fetchRequest.predicate = NSPredicate(format: "id IN %@", userFoods.map { $0.id })
//
//        do {
//            let userFoodEntities = try self.viewContext.fetch(fetchRequest)
//
//            guard userFoodEntities.count == userFoods.count else {
//                throw CoreDataManagerError.mismatchingUserFoodEntities
//            }
//
//            for userFoodEntity in userFoodEntities {
//                userFoodEntity.syncStatus = syncStatus.rawValue
//            }
//
//            do {
//                try viewContext.save()
//            } catch {
//                throw CoreDataManagerError.saveInChangeSyncStatusOfUserFoods(error)
//            }
//
//        } catch {
//            throw CoreDataManagerError.fetchUserFoods(error)
//        }
//
//    }
//
//    func changeSyncStatus(ofImageWith id: UUID, to syncStatus: SyncStatus) throws {
//        let fetchRequest = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
//
//        do {
//            let imageEntities = try self.viewContext.fetch(fetchRequest)
//            guard let imageEntity = imageEntities.first else {
//                throw CoreDataManagerError.missingImageFileEntity
//            }
//            guard imageEntities.count == 1 else {
//                throw CoreDataManagerError.duplicateImageFileEntities
//            }
//
//            imageEntity.syncStatus = syncStatus.rawValue
//
//            do {
//                try viewContext.save()
//            } catch {
//                throw CoreDataManagerError.saveInChangeSyncStatusOfImage(error)
//            }
//
//        } catch {
//            throw CoreDataManagerError.fetchImageFile(error)
//        }
//    }
//
//    func changeSyncStatus(ofJsonWith id: UUID, to syncStatus: SyncStatus) throws {
//        let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
//
//        do {
//            let userFoodEntities = try self.viewContext.fetch(fetchRequest)
//            guard let userFoodEntity = userFoodEntities.first else {
//                throw CoreDataManagerError.missingUserFoodEntity
//            }
//            guard userFoodEntities.count == 1 else {
//                throw CoreDataManagerError.multipleUserFoodsForTheSameId
//            }
//
//            userFoodEntity.jsonSyncStatus = syncStatus.rawValue
//
//            do {
//                try viewContext.save()
//            } catch {
//                throw CoreDataManagerError.saveInChangeSyncStatusOfJson(error)
//            }
//        } catch {
//            throw CoreDataManagerError.fetchUserFoodForJson(error)
//        }
//    }
}

enum CoreDataManagerError: Error {
    case mismatchingUserFoodEntities
    case duplicateImageFileEntities
    case missingImageFileEntity
    case multipleUserFoodsForTheSameId
    case missingUserFoodEntity
    
    case saveInChangeSyncStatusOfUserFoods(Error)
    case saveInChangeSyncStatusOfImage(Error)
    case saveInChangeSyncStatusOfJson(Error)

    case fetchUserFoods(Error)
    case fetchImageFile(Error)
    case fetchUserFoodForJson(Error)
}
