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
    func update(with serverUser: User, in context: NSManagedObjectContext) throws {
        id = serverUser.id
        prefersMetricUnits = serverUser.prefersMetricUnits
        preferredEnergyUnit = serverUser.preferredEnergyUnit.rawValue
        explicitVolumeUnits = try! JSONEncoder().encode(serverUser.explicitVolumeUnits)
        bodyMeasurements = try! JSONEncoder().encode(serverUser.bodyMeasurements)
        updatedAt = serverUser.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
}
