import Foundation
import CoreData
import PrepDataTypes

//MARK: JSONFile → JSONFileEntity
extension JSONFileEntity {
    convenience init(context: NSManagedObjectContext, jsonFile: JSONFile) {
        self.init(context: context)
        self.id = jsonFile.id
        self.syncStatus = jsonFile.syncStatus.rawValue
    }
}
