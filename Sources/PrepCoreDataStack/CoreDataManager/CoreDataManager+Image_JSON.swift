import Foundation
import CoreData
import PrepDataTypes

extension CoreDataManager {

    func fileEntitiesPendingSync(completion: @escaping ((PendingFileEntities?) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {
                do {
                    
                    let imagesRequest = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
                    imagesRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                    let imageFileEntities = try bgContext.fetch(imagesRequest)

                    let jsonsRequest = NSFetchRequest<JSONFileEntity>(entityName: "JSONFileEntity")
                    jsonsRequest.predicate = NSPredicate(format: "syncStatus == %d", SyncStatus.notSynced.rawValue)
                    let jsonFileEntities = try bgContext.fetch(jsonsRequest)
                    
                    completion(
                        PendingFileEntities(
                            imageFileEntities: imageFileEntities,
                            jsonFileEntities: jsonFileEntities)
                    )
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
        }
    }
}

struct PendingFileEntities {
    let imageFileEntities: [ImageFileEntity]
    let jsonFileEntities: [JSONFileEntity]
}
