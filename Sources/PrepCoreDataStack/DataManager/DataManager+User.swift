import Foundation
import PrepDataTypes

extension DataManager {
    func fetchUser() throws {
        guard let user = try coreDataManager.userEntity(context: coreDataManager.viewContext) else {
            return
        }
        self.user = User(from: user)
    }
    
    public func createUser(cloudKitId: String) throws {
        /// Create a new user
        //TODO: Feed in the locale here and get init to choose units accordingly
        let user = User(cloudKitId: cloudKitId)
        let entity = UserEntity(
            context: coreDataManager.viewContext,
            user: user
        )
        
        try coreDataManager.save(entity)
        self.user = user
    }    
}
