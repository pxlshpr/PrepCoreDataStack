import Foundation

extension DataManager {
    func getFilesPendingSync() async throws -> PendingFiles {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.fileEntitiesPendingSync { pendingFileEntities in
                    guard let pendingFileEntities else {
                        continuation.resume(returning: PendingFiles(
                            images: [], jsons: []
                        ))
                        return
                    }
                    continuation.resume(returning: PendingFiles(
                        images: pendingFileEntities.imageFileEntities.compactMap { $0.id },
                        jsons: pendingFileEntities.jsonFileEntities.compactMap { $0.id }
                    ))
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

struct PendingFiles {
    let images: [UUID]
    let jsons: [UUID]
}
