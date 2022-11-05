import Foundation
import CoreData
import PrepDataTypes


//MARK: ImageFile → ImageFileEntity
extension ImageFileEntity {
    convenience init(context: NSManagedObjectContext, imageFile: ImageFile) {
        self.init(context: context)
        self.id = imageFile.id
        self.syncStatus = imageFile.syncStatus.rawValue
    }
}
