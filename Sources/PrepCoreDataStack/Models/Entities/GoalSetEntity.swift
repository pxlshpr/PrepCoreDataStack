import Foundation
import PrepDataTypes
import CoreData

//MARK: GoalSet → GoalSetEntity
extension GoalSetEntity {
    convenience init(context: NSManagedObjectContext, goalSet: GoalSet) {
        self.init(context: context)
        self.id = goalSet.id
        self.name = goalSet.name
        self.emoji = goalSet.emoji
        self.type = Int16(goalSet.type.rawValue)
        self.goals = try! JSONEncoder().encode(goalSet.goals)
        self.syncStatus = Int16(goalSet.syncStatus.rawValue)
        self.updatedAt = goalSet.updatedAt
        self.deletedAt = goalSet.deletedAt ?? 0
    }
}

extension GoalSetEntity {
    func update(with serverGoalSet: GoalSet, in context: NSManagedObjectContext) throws {
        name = serverGoalSet.name
        emoji = serverGoalSet.emoji
        type = Int16(serverGoalSet.type.rawValue)
        goals = try! JSONEncoder().encode(serverGoalSet.goals)
        syncStatus = SyncStatus.synced.rawValue
        updatedAt = serverGoalSet.updatedAt
    }
}
