import Foundation
import PrepDataTypes

extension SyncManager {
    var updates: SyncForm.Updates {
        DataManager.shared.syncUpdates
    }
    
    var updatedUser: User? {
        nil
    }
}

extension DataManager {
    var syncUpdates: SyncForm.Updates {
        // TODO: Include all entities that have an updatedAt greater than versionTimestamp
        SyncForm.Updates(
            user: DataManager.shared.updatedUser
        )
    }
}
