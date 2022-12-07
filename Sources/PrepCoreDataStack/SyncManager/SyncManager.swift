import Foundation
import PrepDataTypes

let SyncInterval: Double = 5

public class SyncManager {
    
    let networkManager = NetworkManager.local
    let dataManager = DataManager.shared

    public static let shared = SyncManager()
    
    public var isPaused: Bool = false
    
    var timer = Timer()

    public func startMonitoring() {
        performSync()
        scheduledTimer()
    }
        
    public func pause() {
        isPaused = true
    }
    public func resume() {
        isPaused = false
    }
    
    //MARK: - Private
    
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
        guard !isPaused else {
            print("⚠️ Sync is currently paused")
            return
        }

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

import SwiftUI

extension Color {
 
    func uiColor() -> UIColor {

        if #available(iOS 14.0, *) {
            return UIColor(self)
        }

        let components = self.components()
        return UIColor(red: components.r, green: components.g, blue: components.b, alpha: components.a)
    }

    func components() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {

        let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0

        let result = scanner.scanHexInt64(&hexNumber)
        if result {
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
        }
        return (r, g, b, a)
    }
}
