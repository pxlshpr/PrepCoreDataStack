import Foundation
import PrepDataTypes

//MARK: MealEntity → Meal
public extension Meal {
    init(from entity: MealEntity) {
        let day = Day(from: entity.day!)
        self.init(
            id: entity.id!,
            day: day,
            name: entity.name!,
            time: entity.time,
            markedAsEatenAt: entity.markedAsEatenAt,
            goalWorkoutMinutes: Int(entity.goalWorkoutMinutes),
            foodItems: [],
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt
        )
    }
}
