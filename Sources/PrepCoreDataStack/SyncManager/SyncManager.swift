import Foundation
import PrepDataTypes

let SyncInterval = 5.0

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
                let deviceSyncForm = try await dataManager.constructSyncForm()
                print("📱→ Sending \(deviceSyncForm.description)")
                let serverSyncForm = try await postSyncForm(deviceSyncForm)
                try await dataManager.process(serverSyncForm, sentFor: deviceSyncForm)
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
        let responseData = try await networkManager.post(syncForm, to: .sync)
        
        guard
            let responseData,
            let syncForm = try? JSONDecoder().decode(SyncForm.self, from: responseData) else {
            throw SyncError.failedToReceiveSyncForm
        }
        return syncForm
    }
}

enum SyncError: Error {
    case failedToReceiveSyncForm
    case syncPerformedWithoutFetchedUser
}
