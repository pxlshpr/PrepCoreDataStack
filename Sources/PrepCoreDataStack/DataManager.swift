import Foundation
import CoreData

public class DataManager: ObservableObject {
    
    public static let shared = DataManager()
    
    let coreDataManager: CoreDataManager
    
    @Published private(set) public var userFoods: [UserFood]
    
    convenience init() {
        self.init(coreDataManager: CoreDataManager())
    }
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        do {
            self.userFoods = try self.coreDataManager.userFoods().map {
                return UserFood(from: $0)
            }
        } catch {
            self.userFoods = []
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
