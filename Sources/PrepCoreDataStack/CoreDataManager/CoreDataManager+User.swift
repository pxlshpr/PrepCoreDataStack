import CoreData

extension CoreDataManager {
    func userEntity() throws -> UserEntity? {
        let fetchRequest = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        let entities = try viewContext.fetch(fetchRequest)
        return entities.first
    }
    
    func save(_ userEntity: UserEntity) throws {
        self.viewContext.insert(userEntity)
        try self.viewContext.save()
    }    
}
