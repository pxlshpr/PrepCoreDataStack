import Foundation
import CoreData
import PrepDataTypes

extension CoreDataManager {

    func fileEntitiesWithSyncStatus(_ syncStatus: SyncStatus, completion: @escaping ((FileEntities?) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {
                do {
                    
                    //TODO: Make this a convenience function
                    let imagesRequest = NSFetchRequest<ImageFileEntity>(entityName: "ImageFileEntity")
                    imagesRequest.predicate = NSPredicate(format: "syncStatus == %d", syncStatus.rawValue)
                    let imageFileEntities = try bgContext.fetch(imagesRequest)

                    let jsonsRequest = NSFetchRequest<JSONFileEntity>(entityName: "JSONFileEntity")
                    jsonsRequest.predicate = NSPredicate(format: "syncStatus == %d", syncStatus.rawValue)
                    let jsonFileEntities = try bgContext.fetch(jsonsRequest)
                    
                    completion(
                        FileEntities(
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

struct FileEntities {
    let imageFileEntities: [ImageFileEntity]
    let jsonFileEntities: [JSONFileEntity]
}
