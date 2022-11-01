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
    }
}
