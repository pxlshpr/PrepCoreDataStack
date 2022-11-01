import Foundation
import PrepDataTypes

//MARK: DayEntity → Day
public extension Day {
    init(from entity: DayEntity) {
        self.init(
            id: entity.id!,
            date: entity.date,
            goal: nil,
            addEnergyExpendituresToGoal: entity.addEnergyExpendituresToGoal,
            goalBonusEnergySplit: GoalBonusEnergySplit(rawValue: entity.goalBonusEnergySplit),
            goalBonusEnergySplitRatio: GoalBonusEnergySplitRatio(rawValue: entity.goalBonusEnergySplitRatio),
            energyExpenditures: [],
            meals: [],
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt
        )
    }
}
