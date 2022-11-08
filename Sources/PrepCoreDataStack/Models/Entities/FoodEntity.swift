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
}

//MARK: UserFoodCreateForm → FoodEntity
public extension FoodEntity {
    convenience init(context: NSManagedObjectContext, form: UserFoodCreateForm) {
        self.init(context: context)
        
        /// Form Values
        self.brand = form.brand
        self.detail = form.detail
        self.emoji = form.emoji
        self.id = form.id
        self.info = try! JSONEncoder().encode(form.info)
        self.name = form.name
        self.publishStatus = form.publishStatus.rawValue
        
        /// Preset values for newly inserted User `Food`s
        self.type = FoodType.food.rawValue
        self.dataset = 0
        self.numberOfTimesConsumedGlobally = 0
        self.numberOfTimesConsumed = 0
        self.syncStatus = SyncStatus.notSynced.rawValue
        self.jsonSyncStatus = SyncStatus.notSynced.rawValue
        self.updatedAt = Date().timeIntervalSince1970
        self.deletedAt = 0
        self.firstUsedAt = 0
        self.lastUsedAt = 0
    }
}
