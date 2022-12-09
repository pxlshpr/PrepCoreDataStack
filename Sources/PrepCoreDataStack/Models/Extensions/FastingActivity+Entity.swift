import Foundation
import PrepDataTypes

//MARK: FastingActivityEntity → FastingActivity
public extension FastingActivity {
    init(from entity: FastingActivityEntity) {
        self.init(
            id: entity.id!,
            pushToken: entity.pushToken!,
            lastMealAt: entity.lastMealAt,
            nextMealAt: entity.nextMealAt == 0 ? nil : entity.nextMealAt,
            nextMealName: entity.nextMealName,
            countdownType: FastingTimerCountdownType(rawValue: entity.countdownType)!,
            syncStatus: SyncStatus(rawValue: entity.syncStatus)!,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt == 0 ? nil : entity.deletedAt
        )
    }
}

