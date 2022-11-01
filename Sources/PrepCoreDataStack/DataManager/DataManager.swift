import Foundation
import CoreData
import PrepDataTypes

public class DataManager: ObservableObject {
    
    public static let shared = DataManager()
    
    let coreDataManager: CoreDataManager
    
    @Published internal(set) public var user: User? = nil

    convenience init() {
        self.init(coreDataManager: CoreDataManager())
    }
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        do {
            try fetchUser()
        } catch {
            print("CoreData error while fetching user")
        }
    }
}
