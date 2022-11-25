import Foundation
import PrepDataTypes

extension DataManager {
    func getFilesWithSyncStatus(_ syncStatus: SyncStatus) async throws -> FoodFiles {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.fileEntitiesWithSyncStatus(syncStatus) { fileEntities in
                    guard let fileEntities else {
                        continuation.resume(returning: FoodFiles.empty)
                        return
                    }
                    
                    let imageFiles = fileEntities.imageFileEntities.map { ImageFile(from: $0) }
                    let jsonFiles = fileEntities.jsonFileEntities.map { JSONFile(from: $0) }
                    let foodFiles = FoodFiles(imageFiles: imageFiles, jsonFiles: jsonFiles)
                    continuation.resume(returning: foodFiles)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

struct FoodFiles {
    let imageFiles: [ImageFile]
    let jsonFiles: [JSONFile]
    
    static var empty: FoodFiles {
        Self.init(imageFiles: [], jsonFiles: [])
    }
}
