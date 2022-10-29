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
    
    //MARK: UserFood
    func userFoods() throws -> [UserFoodEntity] {
        let fetchRequest = NSFetchRequest<UserFoodEntity>(entityName: "UserFoodEntity")
        return try self.viewContext.fetch(fetchRequest)
    }
    
    func saveUserFood(entity: UserFoodEntity) throws {
        self.viewContext.insert(entity)
        try self.viewContext.save()
    }
    
    //MARK: ImageFile
    func imageFiles() throws -> [ImageFileEntity] {
        let fetchRequest = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
        return try self.viewContext.fetch(fetchRequest)
    }
    
    func saveImageFile(entity: ImageFileEntity) throws {
        self.viewContext.insert(entity)
        try self.viewContext.save()
    }
}
