import Foundation
import PrepDataTypes

//MARK: GoalSetEntity → GoalSet
public extension GoalSet {
    init(from entity: GoalSetEntity) {
        self.init(
            id: entity.id!,
            name: entity.name!,
            emoji: entity.emoji!,
            goals: try! JSONDecoder().decode([Goal].self, from: entity.goals!),
            isForMeal: entity.isForMeal,
            syncStatus: SyncStatus(rawValue: entity.syncStatus)!,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt > 0 ? entity.deletedAt : 0
        )
    }
}
