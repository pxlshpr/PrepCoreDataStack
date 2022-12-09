import Foundation
import PrepDataTypes
import CoreData

//MARK: FastingActivity → FastingActivityEntity
extension FastingActivityEntity {
    convenience init(context: NSManagedObjectContext, fastingActivity: FastingActivity) {
        self.init(context: context)
        self.id = fastingActivity.id
        self.pushToken = fastingActivity.pushToken
        
        self.lastMealAt = fastingActivity.lastMealAt
        self.nextMealAt = fastingActivity.nextMealAt ?? 0
        self.nextMealName = fastingActivity.nextMealName
        self.countdownType = fastingActivity.countdownType.rawValue
        
        self.syncStatus = fastingActivity.syncStatus.rawValue
        self.updatedAt = fastingActivity.updatedAt
        self.deletedAt = fastingActivity.deletedAt ?? 0
    }    
}

extension FastingActivityEntity {
    func update(with fastingTimerState: FastingTimerState) {
        self.lastMealAt = fastingTimerState.lastMealTime.timeIntervalSince1970
        self.nextMealAt = fastingTimerState.nextMealTime?.timeIntervalSince1970 ?? 0
        self.nextMealName = fastingTimerState.nextMealName
        self.countdownType = fastingTimerState.countdownType.rawValue
        self.syncStatus = SyncStatus.notSynced.rawValue
        self.updatedAt = Date().timeIntervalSince1970
    }
    
    func update(with serverFastingActivity: FastingActivity, context: NSManagedObjectContext) {
        self.lastMealAt = serverFastingActivity.lastMealAt
        self.nextMealAt = serverFastingActivity.nextMealAt ?? 0
        self.nextMealName = serverFastingActivity.nextMealName
        self.countdownType = serverFastingActivity.countdownType.rawValue
        self.syncStatus = SyncStatus.synced.rawValue
        self.updatedAt = Date().timeIntervalSince1970
    }
}

