import Foundation
import PrepDataTypes

//MARK: BarcodeEntity → Barcode
public extension Barcode {
    init(from entity: BarcodeEntity) {
        self.init(
            id: entity.id!,
            payload: entity.payload!,
            symbology: BarcodeSymbology(rawValue: entity.symbology)!
        )
    }
}
