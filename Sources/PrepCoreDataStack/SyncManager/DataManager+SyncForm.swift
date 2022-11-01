import Foundation
import PrepDataTypes

extension DataManager {

    func constructSyncForm() async throws -> SyncForm {
        guard let userId = user?.id else {
            throw SyncError.syncPerformedWithoutFetchedUser
        }
        
        let updates = try await constructSyncUpdates()
        let deletions = syncDeletions
        return SyncForm(
            updates: updates,
            deletions: deletions,
            userId: userId,
            versionTimestamp: versionTimestamp
        )
    }

    var syncDeletions: SyncForm.Deletions {
        //TODO: Include all entities (except `UserEntity`) with a deletedAt greater than versionTimestamp
        SyncForm.Deletions()
    }

    /// Include all entities that have an updatedAt greater than versionTimestamp
    func constructSyncUpdates() async throws -> SyncForm.Updates {
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

import CoreData

extension DataManager {
    func process(_ syncForm: SyncForm) async throws {
        guard let userId = user?.id else {
            throw SyncError.syncPerformedWithoutFetchedUser
        }
        
        print("💧→ Received \(syncForm.description)")

        if let updates = syncForm.updates {
            try await processUpdates(updates)
        }
        
        processDeletions()
        versionTimestamp = syncForm.versionTimestamp
    }
    
    
    func processDeletions() {
        //TODO: For each entity in deletions
        // If device.updatedAt < server.deletedAt
        //     delete the entity, make sure we do it in the correct order depending on entity type
        // Else
        //     do not delete as we've had edits to the object since the deletion occured
    }
    
    func processUpdates(_ updates: SyncForm.Updates) async throws {
        
        let bgContext =  coreDataManager.newBackgroundContext()
        await bgContext.perform {

            do {
                if let user = updates.user {
                    try self.updateUser(with: user, context: bgContext)
                }
            } catch {
                print("Error: \(error)")
            }
        }
            
        //TODO: For each entity in updates
        // If it doesn't exist on device,
        //     insert it
        // If it exists, and server.updatedAt > device.updatedAt
        //     update existing object with received, by entity type (updatedAt flag should be set to server's)
    }
    
    func updateUser(with serverUser: User, context: NSManagedObjectContext) throws {
        guard let user else { throw SyncError.syncPerformedWithoutFetchedUser }
        
        /// Convert `User` → `UserEntity`
        let entity = UserEntity(context: context, user: serverUser)
        
        /// Ask `CoreDataManager` to replace our existing user with it
        try coreDataManager.replaceUser(with: entity, in: context)
        
        /// Now fire a notification to inform any interested parties (including ourself)
        NotificationCenter.default.post(name: .coreDataDidUpdateUser, object: nil)
    }
}

extension Notification.Name {
    static var coreDataDidUpdateUser: Notification.Name { return .init("coreDataDidUpdateUser") }
}
