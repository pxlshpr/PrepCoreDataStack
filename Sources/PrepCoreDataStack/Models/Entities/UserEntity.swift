import Foundation
import PrepDataTypes
import CoreData

//MARK: User → UserEntity
extension UserEntity {
    convenience init(context: NSManagedObjectContext, user: User) {
        self.init(context: context)
        self.id = user.id
        self.cloudKitId = user.cloudKitId
        self.units = try! JSONEncoder().encode(user.units)
        self.bodyProfile = try! JSONEncoder().encode(user.bodyProfile)
        self.bodyProfileUpdatedAt = user.bodyProfileUpdatedAt ?? 0
        self.updatedAt = user.updatedAt
        self.syncStatus = user.syncStatus.rawValue
    }
}

extension UserEntity {

    private func update(with user: User) throws {
        id = user.id
        units = try JSONEncoder().encode(user.units)
        bodyProfile = try JSONEncoder().encode(user.bodyProfile)
    }

    /// When updating using a user received from the update, we set it as `synced` and use its `updatedAt` timestamp.
    func updateWithServerUser(_ serverUser: User) throws {
        try update(with: serverUser)
        updatedAt = serverUser.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
    
    /// When updating using a user updated on the device, we set the `updatedAt` timestamp ourselves and set it as `notSynced` so that the changes get synced.
    func updateWithDeviceUser(_ deviceUser: User) throws {
        try update(with: deviceUser)
        updatedAt = Date().timeIntervalSince1970
        syncStatus = SyncStatus.notSynced.rawValue
    }
}
