import Foundation
import PrepDataTypes
import CoreData

//MARK: Food → FoodEntity
extension FoodEntity {
    convenience init(context: NSManagedObjectContext, food: Food) {
        self.init(context: context)
        self.brand = food.brand
        self.dataset = food.dataset?.rawValue ?? 0
        self.deletedAt = food.deletedAt ?? 0
        self.detail = food.detail
        self.emoji = food.emoji
        self.firstUsedAt = food.firstUsedAt ?? 0
        self.id = food.id
        self.info = try! JSONEncoder().encode(food.info)
        self.jsonSyncStatus = food.jsonSyncStatus.rawValue
        self.lastUsedAt = food.lastUsedAt ?? 0
        self.name = food.name
        self.numberOfTimesConsumedGlobally = Int32(food.numberOfTimesConsumedGlobally)
        self.numberOfTimesConsumed = Int32(food.numberOfTimesConsumed)
        self.publishStatus = food.publishStatus?.rawValue ?? 0
        self.syncStatus = Int16(food.syncStatus.rawValue)
        self.type = Int16(food.type.rawValue)
        self.updatedAt = food.updatedAt
    }
    
//    convenience init(
//        context: NSManagedObjectContext,
//        name: String,
//        time: Date,
//        dayEntity: DayEntity
//    ) {
//        self.init(context: context)
//        self.id = UUID()
//        self.name = name
//        self.time = time.timeIntervalSince1970
//        self.markedAsEatenAt = 0
//        self.updatedAt = Date().timeIntervalSince1970
//        self.deletedAt = 0
//        self.day = dayEntity
//        self.syncStatus = SyncStatus.notSynced.rawValue
//    }
}

extension FoodEntity {
//    func update(with serverMeal: Meal, in context: NSManagedObjectContext) throws {
//        id = serverMeal.id
//        name = serverMeal.name
//        time = serverMeal.time
//        markedAsEatenAt = serverMeal.markedAsEatenAt ?? 0
//        updatedAt = serverMeal.updatedAt
//        syncStatus = SyncStatus.synced.rawValue
//    }
}
