import Foundation
import PrepDataTypes
import CoreData

//MARK: Barcode → BarcodeEntity
extension BarcodeEntity {
    convenience init(context: NSManagedObjectContext, foodBarcode: FoodBarcode, foodEntity: FoodEntity) {
        self.init(context: context)
        self.id = UUID()
        self.food = foodEntity
        self.payload = foodBarcode.payload
        self.symbology = foodBarcode.symbology.rawValue
    }
}
