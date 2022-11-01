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
        self.updatedAt = Int32(user.updatedAt.timeIntervalSince1970)
    }
}
