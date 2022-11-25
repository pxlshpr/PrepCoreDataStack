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
        self.isForMeal = goalSet.isForMeal
        self.goals = try! JSONEncoder().encode(goalSet.goals)
        self.syncStatus = Int16(goalSet.syncStatus.rawValue)
        self.updatedAt = goalSet.updatedAt
        self.deletedAt = goalSet.deletedAt ?? 0
    }
}
