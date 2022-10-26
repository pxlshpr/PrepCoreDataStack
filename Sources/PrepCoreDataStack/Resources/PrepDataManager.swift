import Foundation
import CoreData

public class PrepDataManager: ObservableObject {
    let coreDataManager: CoreDataManager
    
    @Published private(set) public var userFoods: [UserFood]
    
    convenience init() throws {
        try self.init(coreDataManager: CoreDataManager())
    }
    
    init(coreDataManager: CoreDataManager) throws {
        self.coreDataManager = coreDataManager
        self.userFoods = try self.coreDataManager.userFoods().map {
            return UserFood(from: $0)
        }
    }
    
    func save(userFood: UserFood) throws {
        let entity = UserFoodEntity(context: self.coreDataManager.viewContext, userFood: userFood)
        try self.coreDataManager.saveUserFood(entity: entity)
        try refresh()
        
    }
    
    func refresh() throws {
        self.userFoods = try self.coreDataManager.userFoods().map {
            return UserFood(from: $0)
        }
    }
    
}

// MARK: - UserFood → Entity conversion
extension UserFood {
    init(from entity: UserFoodEntity) {
        self.id = entity.id!
        self.name = entity.name!
    }
}

extension UserFoodEntity {
    convenience init(context: NSManagedObjectContext, userFood: UserFood) {
        self.init(context: context)
        self.name = userFood.name
        self.id = userFood.id
    }
}
