import Foundation
import PrepDataTypes
import CoreData

public struct UserFood: Identifiable {
    
    public var id: UUID
    public var name: String
    public var emoji: String
    public var detail: String?
    public var brand: String?
    public var barcodes: String
    public var status: UserFoodStatus
    public var info: UserFoodInfo
    public var syncStatus: SyncStatus
    
}

//MARK: UserFood → UserFoodEntity
extension UserFoodEntity {
    convenience init(context: NSManagedObjectContext, userFood: UserFood) {
        self.init(context: context)
        self.id = userFood.id
        self.name = userFood.name
        self.emoji = userFood.emoji
        self.detail = userFood.detail
        self.brand = userFood.brand
        self.barcodes = userFood.barcodes
        self.status = userFood.status.rawValue
        self.info = try! JSONEncoder().encode(userFood.info)
        self.syncStatus = userFood.syncStatus.rawValue
    }
}

public extension UserFood {
    
    //MARK: UserFoodEntity → UserFood
    init(from entity: UserFoodEntity) {
        self.id = entity.id!
        self.name = entity.name!
        self.emoji = entity.emoji!
        self.detail = entity.detail
        self.brand = entity.brand
        self.barcodes = entity.barcodes!
        self.status = UserFoodStatus(rawValue: entity.status)!
        self.info = try! JSONDecoder().decode(UserFoodInfo.self, from: entity.info!)
        
        self.syncStatus = SyncStatus(rawValue: entity.syncStatus)!
    }
    
    //MARK: UserFoodCreateForm → UserFood
    init(from form: UserFoodCreateForm) {
        self.id = form.id
        self.name = form.name
        self.emoji = form.emoji
        self.detail = form.detail
        self.brand = form.brand
        self.barcodes = form.info.barcodes.map { $0.payload }.joined(separator: ";")
        self.status = form.status
        self.info = form.info
        
        self.syncStatus = .notSynced
    }
}

public extension UserFood {
    var createForm: UserFoodCreateForm {
        UserFoodCreateForm(
            id: id,
            name: name,
            emoji: emoji,
            detail: detail,
            brand: brand,
            status: status,
            info: info
        )
    }
}
