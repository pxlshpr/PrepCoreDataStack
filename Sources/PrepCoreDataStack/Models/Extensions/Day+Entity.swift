import Foundation
import PrepDataTypes

//MARK: DayEntity → Day
public extension Day {
    init(from entity: DayEntity) {
        let goalSet: GoalSet?
        if let diet = entity.goalSet {
            goalSet = GoalSet(from: diet)
        } else {
            goalSet = nil
        }
        
        let bodyProfile: BodyProfile?
        if let bodyProfileData = entity.bodyProfile {
            bodyProfile = try? JSONDecoder().decode(BodyProfile.self, from: bodyProfileData)
        } else {
            bodyProfile = nil
        }

        self.init(
            id: entity.id!,
            calendarDayString: entity.calendarDayString!,
            goalSet: goalSet,
            bodyProfile: bodyProfile,
            meals: entity.dayMeals,
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt
        )
    }
}
