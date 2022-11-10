import Foundation
import PrepDataTypes
import CoreData

//MARK: User → UserEntity
extension UserEntity {
    convenience init(context: NSManagedObjectContext, user: User) {
        self.init(context: context)
        self.id = user.id
        self.cloudKitId = user.cloudKitId
        self.preferredEnergyUnit = user.preferredEnergyUnit.rawValue
        self.prefersMetricUnits = user.prefersMetricUnits
        self.explicitVolumeUnits = try! JSONEncoder().encode(user.explicitVolumeUnits)
        self.bodyMeasurements = try! JSONEncoder().encode(user.bodyMeasurements)
        self.updatedAt = user.updatedAt
        self.syncStatus = user.syncStatus.rawValue
    }
}

extension UserEntity {

    private func update(with user: User) throws {
        id = user.id
        prefersMetricUnits = user.prefersMetricUnits
        preferredEnergyUnit = user.preferredEnergyUnit.rawValue
        explicitVolumeUnits = try JSONEncoder().encode(user.explicitVolumeUnits)
        bodyMeasurements = try JSONEncoder().encode(user.bodyMeasurements)
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
