import Foundation
import PrepDataTypes

//MARK: FoodEntity → Food
public extension Food {
    init(from entity: FoodEntity) {
        
        let barcodeEntities: [BarcodeEntity] = entity.barcodes?.allObjects as? [BarcodeEntity] ?? []
        let barcodes = barcodeEntities.map { Barcode(from: $0) }
        self.init(
            id: entity.id!,
            type: FoodType(rawValue: entity.type)!,
            name: entity.name!,
            emoji: entity.emoji!,
            detail: entity.detail,
            brand: entity.brand,
            numberOfTimesConsumedGlobally: Int(entity.numberOfTimesConsumedGlobally),
            numberOfTimesConsumed: Int(entity.numberOfTimesConsumed),
            lastUsedAt: entity.lastUsedAt,
            firstUsedAt: entity.firstUsedAt,
            info: try! JSONDecoder().decode(FoodInfo.self, from: entity.info!),
            publishStatus: UserFoodPublishStatus(rawValue: entity.publishStatus),
            jsonSyncStatus: SyncStatus(rawValue: entity.jsonSyncStatus)!,
            childrenFoods: nil,
            dataset: FoodDataset(rawValue: entity.dataset),
            barcodes: barcodes,
            syncStatus: SyncStatus(rawValue: entity.syncStatus)!,
            updatedAt: entity.updatedAt
        )
    }
}
