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
        }
    }    
}
