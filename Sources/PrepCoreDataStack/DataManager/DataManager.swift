import Foundation
import CoreData
import PrepDataTypes

public class DataManager: ObservableObject {
    
    public static let shared = DataManager()
    
    let coreDataManager: CoreDataManager
    
    @Published internal(set) public var user: User? = nil

    convenience init() {
        self.init(coreDataManager: CoreDataManager())
        coreDataManager.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        do {
            try fetchUser()
        } catch {
            print("CoreData error while fetching user: \(error)")
        }
        
        /// Add an observer for any changes to the User (from another device)
        NotificationCenter.default.addObserver(
            self, selector: #selector(serverDidUpdateUser),
            name: .didUpdateUser, object: nil
        )
    }
    
    @objc func serverDidUpdateUser(notification: Notification) {
        DispatchQueue.main.async {
            do {
                try self.fetchUser()
            } catch {
                print("CoreData error while updating user: \(error)")
            }
        }
    }
}
