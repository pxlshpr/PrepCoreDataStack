import Foundation
import PrepDataTypes
import CoreData

//MARK: Meal → MealEntity
extension MealEntity {
    convenience init(context: NSManagedObjectContext, meal: Meal, dayEntity: DayEntity) {
        self.init(context: context)
        self.id = meal.id
        self.day = dayEntity
        self.name = meal.name
        self.time = meal.time
        self.markedAsEatenAt = meal.markedAsEatenAt ?? 0
        self.updatedAt = meal.updatedAt
        self.deletedAt = meal.deletedAt ?? 0
        self.syncStatus = meal.syncStatus.rawValue
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
        self.syncStatus = SyncStatus.notSynced.rawValue
    }
}

extension MealEntity {
    func update(with serverMeal: Meal, in context: NSManagedObjectContext) throws {
        id = serverMeal.id
        name = serverMeal.name
        time = serverMeal.time
        markedAsEatenAt = serverMeal.markedAsEatenAt ?? 0
        updatedAt = serverMeal.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
}
