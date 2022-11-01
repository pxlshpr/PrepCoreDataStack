//import Foundation
//import CoreData
//
//public struct ImageFile: Identifiable {
//    public var id: UUID
//    public var syncStatus: SyncStatus
//    
//}
//
////MARK: ImageFile → ImageFileEntity
//extension ImageFileEntity {
//    convenience init(context: NSManagedObjectContext, imageFile: ImageFile) {
//        self.init(context: context)
//        self.id = imageFile.id
//        self.syncStatus = imageFile.syncStatus.rawValue
//    }
//}
//
////MARK: ImageFileEntity → ImageFile
//public extension ImageFile {
//    init(from entity: ImageFileEntity) {
//        self.id = entity.id!
//        self.syncStatus = SyncStatus(rawValue: entity.syncStatus)!
//    }    
//}
