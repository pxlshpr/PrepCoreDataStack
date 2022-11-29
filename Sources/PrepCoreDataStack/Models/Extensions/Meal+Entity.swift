import Foundation
import PrepDataTypes

//MARK: MealEntity → Meal
public extension Meal {
    init(from entity: MealEntity) {
        
        let day = Day(from: entity.day!)
        
        let goalSet: GoalSet?
        if let mealType = entity.mealType {
            goalSet = GoalSet(from: mealType)
        } else {
            goalSet = nil
        }
        
        self.init(
            id: entity.id!,
            day: day,
            name: entity.name!,
            time: entity.time,
            markedAsEatenAt: entity.markedAsEatenAt,
            goalSet: goalSet,
            goalWorkoutMinutes: Int(entity.goalWorkoutMinutes),
            foodItems: entity.mealFoodItems,
            syncStatus: SyncStatus(rawValue: entity.syncStatus) ?? .notSynced,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt
        )
    }
}
