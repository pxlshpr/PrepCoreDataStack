import Foundation
import PrepDataTypes

extension DataManager {
    func fetchUser() throws {
        guard let user = try coreDataManager.userEntity() else {
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
    
    /// Returns the `User` if updated since the last `versionTimestamp` (which includes a newly created one)
    var updatedUser: User? {
        guard
            let user = user,
            user.updatedAt > versionDate
        else {
            return nil
        }
        return user
    }
}
