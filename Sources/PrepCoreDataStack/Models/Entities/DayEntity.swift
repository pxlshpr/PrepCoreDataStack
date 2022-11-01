import Foundation
import PrepDataTypes
import CoreData

//MARK: Day → DayEntity
extension DayEntity {
    convenience init(context: NSManagedObjectContext, day: Day) {
        self.init(context: context)
        self.id = day.id
        self.date = day.date
        self.addEnergyExpendituresToGoal = day.addEnergyExpendituresToGoal
        self.goalBonusEnergySplit = day.goalBonusEnergySplit?.rawValue ?? 0
        self.goalBonusEnergySplitRatio = day.goalBonusEnergySplitRatio?.rawValue ?? 0
        self.updatedAt = day.updatedAt
        self.syncStatus = day.syncStatus.rawValue
    }
    
    convenience init(context: NSManagedObjectContext, date: Date) {
        self.init(context: context)
        self.id = UUID()
        self.date = date.startOfDay.timeIntervalSince1970
        
        //TODO: Get these passed in, or read from UserDefaults, etc...
        self.addEnergyExpendituresToGoal = false
        self.goalBonusEnergySplit = 0
        self.goalBonusEnergySplitRatio = 0
        
        self.updatedAt = Date().timeIntervalSince1970
        self.syncStatus = SyncStatus.notSynced.rawValue
    }
}
