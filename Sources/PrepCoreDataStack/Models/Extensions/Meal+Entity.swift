import Foundation
import PrepDataTypes

//MARK: MealEntity → Meal
public extension Meal {
    init(from entity: MealEntity, day: Day) {
        self.init(
            id: entity.id!,
            day: day,
            name: entity.name!,
            time: entity.time,
            markedAsEatenAt: entity.markedAsEatenAt,
            foodItems: [],
            syncStatus: .notSynced,
            updatedAt: entity.updatedAt,
            deletedAt: entity.deletedAt
        )
    }
}