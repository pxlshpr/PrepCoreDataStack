import Foundation
import CoreData

public class PrepDataManager: ObservableObject {
    let coreDataManager: CoreDataManager
    
    @Published private(set) public var userFoods: [UserFood]
    
    public convenience init() throws {
        try self.init(coreDataManager: CoreDataManager())
    }
    
    init(coreDataManager: CoreDataManager) throws {
        self.coreDataManager = coreDataManager
        self.userFoods = try self.coreDataManager.userFoods().map {
            return UserFood(from: $0)
        }
    }
    
    public func save(userFood: UserFood) throws {
        let entity = UserFoodEntity(context: self.coreDataManager.viewContext, userFood: userFood)
        try self.coreDataManager.saveUserFood(entity: entity)
        try refresh()
        
    }
    
    public func refresh() throws {
        self.userFoods = try self.coreDataManager.userFoods().map {
            return UserFood(from: $0)
        }
    }
}
