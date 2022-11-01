import Foundation
import PrepDataTypes

let SyncInterval = 5.0

public class SyncManager {
    
    public static let shared = SyncManager()

    var timer = Timer()

    public func startMonitoring() {
        performSync()
        scheduledTimer()
    }
    
    func scheduledTimer() {
        DispatchQueue.global(qos: .utility).async {
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(
                timeInterval: SyncInterval,
                target: self,
                selector: #selector(self.performSync),
                userInfo: nil,
                repeats: true
            )
            RunLoop.current.add(self.timer, forMode: .common)
            RunLoop.current.run()
        }
    }
    
    @objc func performSync() {
        Task {
            do {
                let syncForm = try await DataManager.shared.getSyncForm()
//                print(syncForm.description)
                process(try await postSyncForm(syncForm))
            } catch NetworkManagerError.httpError(let statusCode) {
                let status = statusCode != nil ? "\(statusCode!)" : "[no status code]"
                print("◽️⚠️ SyncError: HTTP status code \(status)")
            } catch NetworkManagerError.couldNotConnectToServer {
                print("◽️⚠️ SyncError: Could not connect to server")
            } catch {
                print("◽️⚠️ SyncError: \(error)")
            }
        }
    }
    
    func postSyncForm(_ syncForm: SyncForm) async throws -> SyncForm {
        let responseData = try await NetworkManager.local.post(syncForm, to: .sync)
        
        guard
            let responseData,
            let syncForm = try? JSONDecoder().decode(SyncForm.self, from: responseData) else {
            throw SyncError.failedToReceiveSyncForm
        }
        return syncForm
    }
    
    func process(_ syncForm: SyncForm) {
        func processUpdates() {
            //TODO: For each entity in updates
            // If it doesn't exist on device,
            //     insert it
            // If it exists, and server.updatedAt > device.updatedAt
            //     update existing object with received, by entity type (updatedAt flag should be set to server's)
        }
        
        func processDeletions() {
            //TODO: For each entity in deletions
            // If device.updatedAt < server.deletedAt
            //     delete the entity, make sure we do it in the correct order depending on entity type
            // Else
            //     do not delete as we've had edits to the object since the deletion occured
        }
        
        func setNewVersionTimestamp() {
            versionTimestamp = syncForm.versionTimestamp
        }
        
        processUpdates()
        processDeletions()
        setNewVersionTimestamp()
    }
}

enum SyncError: Error {
    case failedToReceiveSyncForm
}
