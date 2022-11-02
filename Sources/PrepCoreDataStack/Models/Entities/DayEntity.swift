import Foundation
import PrepDataTypes
import CoreData

//MARK: Day → DayEntity
extension DayEntity {
    convenience init(context: NSManagedObjectContext, day: Day) {
        self.init(context: context)
        self.id = day.id
        self.calendarDayString = day.calendarDayString
        self.addEnergyExpendituresToGoal = day.addEnergyExpendituresToGoal
        self.goalBonusEnergySplit = day.goalBonusEnergySplit?.rawValue ?? 0
        self.goalBonusEnergySplitRatio = day.goalBonusEnergySplitRatio?.rawValue ?? 0
        self.updatedAt = day.updatedAt
        self.syncStatus = day.syncStatus.rawValue
    }
    
    convenience init(context: NSManagedObjectContext, date: Date, userId: UUID) {
        self.init(context: context)
        self.id = "\(userId.uuidString.lowercased())_\(Int(date.startOfDay.timeIntervalSince1970))"
        self.calendarDayString = date.calendarDayString
        
        //TODO: Get these passed in, or read from UserDefaults, etc...
        self.addEnergyExpendituresToGoal = false
        self.goalBonusEnergySplit = 0
        self.goalBonusEnergySplitRatio = 0
        
        self.updatedAt = Date().timeIntervalSince1970
        self.syncStatus = SyncStatus.notSynced.rawValue
    }
}

extension DayEntity {
    func update(with serverDay: Day, in context: NSManagedObjectContext) throws {
        id = serverDay.id
        addEnergyExpendituresToGoal = serverDay.addEnergyExpendituresToGoal
        goalBonusEnergySplit = serverDay.goalBonusEnergySplit?.rawValue ?? 0
        goalBonusEnergySplitRatio = serverDay.goalBonusEnergySplitRatio?.rawValue ?? 0
        updatedAt = serverDay.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
}
