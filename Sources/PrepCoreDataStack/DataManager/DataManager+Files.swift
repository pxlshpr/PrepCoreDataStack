import Foundation

extension DataManager {
    func getFilesNotSynced() async throws -> FileIds {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.fileEntitiesNotSynced { fileEntities in
                    guard let fileEntities else {
                        continuation.resume(returning: FileIds(
                            images: [], jsons: []
                        ))
                        return
                    }
                    continuation.resume(returning: FileIds(
                        images: fileEntities.imageFileEntities.compactMap { $0.id },
                        jsons: fileEntities.jsonFileEntities.compactMap { $0.id }
                    ))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

struct FileIds {
    let images: [UUID]
    let jsons: [UUID]
}
