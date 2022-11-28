import Foundation
import PrepDataTypes

//MARK: DayEntity → Day
public extension Day {
    init(from entity: DayEntity) {
        let goalSet: GoalSet?
        if let diet = entity.diet {
            goalSet = GoalSet(from: diet)
        } else {
            goalSet = nil
        }
        self.init(
            id: entity.id!,
            calendarDayString: entity.calendarDayString!,
            goalSet: goalSet,
            meals: entity.dayMeals,
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt
        )
    }
}
