import Foundation
import PrepDataTypes

extension SyncManager {
    
    var syncForm: SyncForm {
        DataManager.shared.syncForm
    }
}

extension DataManager {
    var syncForm: SyncForm {
        SyncForm(
            updates: syncUpdates,
            deletions: syncDeletions,
            versionTimestamp: versionTimestamp
        )
    }

    func getSyncForm() async throws -> SyncForm {
        let updates = try await getSyncUpdates()
        let deletions = syncDeletions
        return SyncForm(
            updates: updates,
            deletions: deletions,
            versionTimestamp: versionTimestamp
        )
    }

    var syncDeletions: SyncForm.Deletions {
        //TODO: Include all entities (except `UserEntity`) with a deletedAt greater than versionTimestamp
        SyncForm.Deletions()
    }

    var syncUpdates: SyncForm.Updates {
        SyncForm.Updates(
            user: updatedUser
        )
    }
    
    /// Include all entities that have an updatedAt greater than versionTimestamp
    func getSyncUpdates() async throws -> SyncForm.Updates {
        try await withCheckedThrowingContinuation { continuation in
            coreDataManager.updatedEntities { updatedEntities in
                var user: User? = nil
                if let userEntity = updatedEntities.userEntity {
                    user = User(from: userEntity)
                }
                
                let updated = SyncForm.Updates(
                    user: user
                )

                continuation.resume(returning: updated)
            }
        }
    }
    
    var updatedUser: User? {
        guard
            let user = user,
            user.updatedAt > versionTimestamp
        else {
            return nil
        }
        return user
    }
}
