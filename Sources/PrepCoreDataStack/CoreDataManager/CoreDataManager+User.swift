import CoreData

extension CoreDataManager {
    func userEntity() throws -> UserEntity? {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        return try viewContext.fetch(fetchRequest).first
    }
    
    func save(_ userEntity: UserEntity) throws {
        self.viewContext.insert(userEntity)
        try self.viewContext.save()
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
                let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
                fetchRequest.predicate = NSPredicate(format: "updatedAt > %f", versionTimestamp)
                let userEntity = try bgContext.fetch(fetchRequest).first
                
                let updatedEntites = UpdatedEntities(
                    userEntity: userEntity
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
}
