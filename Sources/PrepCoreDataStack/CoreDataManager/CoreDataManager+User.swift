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
}

extension CoreDataManager {
    func updatedEntities(completion: ((UpdatedEntities) -> ())) {
        let bgContext = newBackgroundContext()
        do {
            try bgContext.performAndWait {
                
                let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
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
