import Foundation
import PrepDataTypes
import CoreData

//MARK: Meal → MealEntity
extension MealEntity {
    convenience init(context: NSManagedObjectContext, meal: Meal) {
        self.init(context: context)
        self.id = meal.id
        self.name = meal.name
        self.time = meal.time
        self.markedAsEatenAt = meal.markedAsEatenAt ?? 0
        self.updatedAt = meal.updatedAt
        self.deletedAt = meal.deletedAt ?? 0
    }
}
