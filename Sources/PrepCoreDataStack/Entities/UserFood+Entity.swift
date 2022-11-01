//import Foundation
//import PrepDataTypes
//import CoreData
//
////MARK: UserFood → UserFoodEntity
//extension UserFoodEntity {
//    convenience init(context: NSManagedObjectContext, food: Food) {
//        self.init(context: context)
//        self.id = food.id
//        self.name = userFood.name
//        self.emoji = userFood.emoji
//        self.detail = userFood.detail
//        self.brand = userFood.brand
//        self.barcodes = userFood.barcodes
//        self.publishStatus = userFood.publishStatus.rawValue
//        self.info = try! JSONEncoder().encode(userFood.info)
//        self.syncStatus = userFood.syncStatus.rawValue
//    }
//}
//
////MARK: UserFoodEntity → UserFood
//public extension UserFood {
//    init(from entity: UserFoodEntity) {
//        self.id = entity.id!
//        self.name = entity.name!
//        self.emoji = entity.emoji!
//        self.detail = entity.detail
//        self.brand = entity.brand
//        self.barcodes = entity.barcodes!
//        self.publishStatus = UserFoodPublishStatus(rawValue: entity.publishStatus)!
//        self.info = try! JSONDecoder().decode(UserFoodInfo.self, from: entity.info!)
//        
//        self.syncStatus = SyncStatus(rawValue: entity.syncStatus)!
//    }
//}
