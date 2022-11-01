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
    
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        time: Date,
        dayEntity: DayEntity
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.time = time.timeIntervalSince1970
        self.markedAsEatenAt = 0
        self.updatedAt = Date().timeIntervalSince1970
        self.deletedAt = 0
        self.day = dayEntity
    }
}
