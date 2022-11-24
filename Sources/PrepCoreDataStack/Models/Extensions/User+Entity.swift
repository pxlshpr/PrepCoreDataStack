import Foundation
import PrepDataTypes

//MARK: UserEntity → User
public extension User {
    init(from entity: UserEntity) {
        let bodyProfile: BodyProfile?
        if let bodyProfileData = entity.bodyProfile {
            bodyProfile = try? JSONDecoder().decode(BodyProfile.self, from: bodyProfileData)
        } else {
            bodyProfile = nil
        }
        self.init(
            id: entity.id!,
            cloudKitId: entity.cloudKitId,
            units: try! JSONDecoder().decode(UserUnits.self, from: entity.units!),
            bodyProfile: bodyProfile,
            bodyProfileUpdatedAt: entity.bodyProfileUpdatedAt,
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt
        )
    }
}
