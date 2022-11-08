import Foundation
import PrepDataTypes

let SyncInterval = 1.0

public class SyncManager {
    
    let networkManager = NetworkManager.local
    let dataManager = DataManager.shared

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
                
                //TODO: Mark objects being synced as pending so we don't re-fetch them during the sync
                try await sendAndReceiveSyncForms()
                try await uploadPendingFiles()
                try await dataManager.setFiles(.syncing, to: .synced)
                
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
    
    func uploadPendingFiles() async throws {
        let pendingFiles = try await dataManager.getFilesWithSyncStatus(.notSynced)
        print("🐔 We're here with: \(pendingFiles.imageFiles.count) images and \(pendingFiles.jsonFiles.count) json")
        
        //TODO: Add concurrency
        
        /// Mark the files we'll be uploading as `syncing`
        /// so that subsequent calls are prevented from uploading them
        try await dataManager.setFiles(.notSynced, to: .syncing)
        for jsonFile in pendingFiles.jsonFiles {
            
            /// Load json data from file
            //TODO: Get JSONFile to return this
            let url = try jsonFile.getUrl()
            
            let data = try Data(contentsOf: url)
            
            /// Get the `NetworkManager` to post it
            let _ = try await networkManager.postFile(
                type: .json,
                data: data,
                id: jsonFile.id
            )
            print("json file \(jsonFile.id) was uploaded")
        }
        
        for imageFile in pendingFiles.imageFiles {
            
            /// Load image data from file
            let url = try imageFile.getUrl()
            let data = try Data(contentsOf: url)
            
            /// Get the `NetworkManager` to post it
            let _ = try await networkManager.postFile(
                type: .image,
                data: data,
                id: imageFile.id
            )
            print("image file \(imageFile.id) was uploaded")
        }
        
        return
    }
    
    func sendAndReceiveSyncForms() async throws {
        let deviceSyncForm = try await dataManager.constructSyncForm()
        if !deviceSyncForm.isEmpty {
            print("📱→ Sending \(deviceSyncForm.description)")
        }
        let serverSyncForm = try await postSyncForm(deviceSyncForm)
        try await dataManager.process(serverSyncForm, sentFor: deviceSyncForm)
    }
    
    func postSyncForm(_ syncForm: SyncForm) async throws -> SyncForm {
        let responseData = try await networkManager.post(syncForm, to: .sync)
        
        guard let syncForm = try? JSONDecoder().decode(SyncForm.self, from: responseData) else {
            throw SyncError.failedToReceiveSyncForm
        }
        return syncForm
    }
}

enum SyncError: Error {
    case failedToReceiveSyncForm
    case syncPerformedWithoutFetchedUser
}
