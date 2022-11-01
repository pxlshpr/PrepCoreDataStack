import Foundation
import PrepDataTypes

//MARK: UserEntity → User
public extension User {
    init(from entity: UserEntity) {
        self.init(
            id: entity.id!,
            cloudKitId: entity.cloudKitId,
            preferredEnergyUnit: EnergyUnit(rawValue: entity.preferredEnergyUnit)!,
            prefersMetricUnits: entity.prefersMetricUnits,
            explicitVolumeUnits: try! JSONDecoder().decode(UserExplicitVolumeUnits.self, from: entity.explicitVolumeUnits!),
            bodyMeasurements: try! JSONDecoder().decode(BodyMeasurements.self, from: entity.bodyMeasurements!),
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt
        )
    }
}
