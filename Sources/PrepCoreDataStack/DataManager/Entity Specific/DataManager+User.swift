import Foundation
import PrepDataTypes

extension DataManager {
    public var userVolumeUnits: UserExplicitVolumeUnits {
        user?.units.volume ?? .defaultUnits
    }
    
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
        
        try coreDataManager.insertUserEntity(entity)
        self.user = user
    }
    
    public func setUserVolumeUnit(_ volumeExplicitUnit: VolumeExplicitUnit) throws {
        user?.units.volume.set(volumeExplicitUnit)
        try saveUpdatedUser()
    }
    
    func saveUpdatedUser() throws {
        /// Set the flags to include it in the next sync
        self.user?.updatedAt = Date().timeIntervalSince1970
        self.user?.syncStatus = .notSynced
        
        /// Now remove the optionality of `user` and fetch the existing `UserEntity`
        guard let user, let existingUserEntity = try coreDataManager.userEntity(context: coreDataManager.viewContext)
        else { throw DataManagerError.noUserFound }
        
        /// Update the `UserEntity` with the upated `User` and save CoreData
        try existingUserEntity.updateWithDeviceUser(user)
        try coreDataManager.viewContext.save()
    }
}
