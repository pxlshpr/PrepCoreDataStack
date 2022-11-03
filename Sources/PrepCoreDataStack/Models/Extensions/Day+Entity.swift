import Foundation
import PrepDataTypes

//MARK: DayEntity → Day
public extension Day {
    init(from entity: DayEntity) {
        self.init(
            id: entity.id!,
            calendarDayString: entity.calendarDayString!,
            goal: nil,
            addEnergyExpendituresToGoal: entity.addEnergyExpendituresToGoal,
            goalBonusEnergySplit: GoalBonusEnergySplit(rawValue: entity.goalBonusEnergySplit),
            goalBonusEnergySplitRatio: GoalBonusEnergySplitRatio(rawValue: entity.goalBonusEnergySplitRatio),
            energyExpenditures: [],
            meals: entity.dayMeals,
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt
        )
    }
}

extension DayEntity {
    
    var mealEntities: [MealEntity] {
        meals?.allObjects as? [MealEntity] ?? []
    }
    
    var dayMeals: [DayMeal] {
        mealEntities
            .map { DayMeal(from: $0) }
            .sorted(by: { $0.time < $1.time })
    }
}
