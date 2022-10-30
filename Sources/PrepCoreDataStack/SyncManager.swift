import Foundation


struct UploadQueue {
    let userFoods: [UserFood]
    let jsonIds: [UUID]
    let imageIds: [UUID]
    
    var isEmpty: Bool {
        userFoods.isEmpty
        && jsonIds.isEmpty
        && imageIds.isEmpty
    }
}

enum UploadStep {
    case uploadUserFoods
    case uploadImage(UUID)
    case uploadJson(UUID)
}

enum UploadError: Error {
    case uploadUserFoods
}

let MonitorInterval = 5.0

public class SyncManager {
    
    public static let shared = SyncManager()
    
    let dataManager = DataManager.shared
    
    var timer = Timer()
    var isSyncing = false
    
    //MARK: - Monitoring
    
    public func startMonitoring() {
        scheduledTimer()
    }
    
    public func stopMonitoring() {
        timer.invalidate()
    }
    
    func scheduledTimer() {
        let concurrentQueue = DispatchQueue(label: "sync", qos: .background, attributes: .concurrent)
        concurrentQueue.async {
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: MonitorInterval, target: self, selector: #selector(self.uploadNotSyncedData), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: .common)
            RunLoop.current.run()
        }
    }

    //MARK: - Convenience
    
    func getUploadQueue() throws -> UploadQueue {
        let userFoods = try dataManager.userFoodsToSync()
        let jsonIds = try dataManager.userFoodsWithJsonToSync().map { $0.id }
        let imageIds = try dataManager.imageFilesToSync().map { $0.id }
        return UploadQueue(userFoods: userFoods, jsonIds: jsonIds, imageIds: imageIds)
    }
    
    func uploadUserFoods(_ userFoods: [UserFood]) async throws -> Result<UploadStep, UploadError> {
        try dataManager.changeSyncStatus(ofUserFoods: userFoods, to: .syncPending)
        
        
        /// **We're only uploading one to test this**
        let url = URL(string: "https://pxlshpr.app/prep/user_foods")!

        do {
            let encoder = JSONEncoder()
            var createForm = userFoods.first!.createForm
            createForm.info.userId = UUID(uuidString: "B25579FD-26AA-4128-8F97-870DCAECCE9B")!
            let data = try encoder.encode(createForm)

            print("URl is \(url.absoluteString)")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                fatalError("Couldn't get http response")
            }
            if httpResponse.statusCode == 200 {
                try dataManager.changeSyncStatus(ofUserFoods: userFoods, to: .synced)
                return .success(.uploadUserFoods)
            } else {
                try dataManager.changeSyncStatus(ofUserFoods: userFoods, to: .notSynced)
                return .failure(.uploadUserFoods)
            }
        } catch {
            try dataManager.changeSyncStatus(ofUserFoods: userFoods, to: .notSynced)
            return .failure(.uploadUserFoods)
        }
    }
    
    func uploadImage(with id: UUID) async throws -> Result<UploadStep, UploadError> {
        try dataManager.changeSyncStatus(ofImageWith: id, to: .syncPending)
        try await sleepTask(Double.random(in: 1.0...10.0))
        
        try dataManager.changeSyncStatus(ofImageWith: id, to: .synced)
        return .success(.uploadImage(id))
    }
    
    func uploadJson(with id: UUID) async throws -> Result<UploadStep, UploadError> {
        try dataManager.changeSyncStatus(ofJsonWith: id, to: .syncPending)
        try await sleepTask(Double.random(in: 1.0...10.0))
        
        try dataManager.changeSyncStatus(ofJsonWith: id, to: .synced)
        return .success(.uploadJson(id))
    }
    
    @objc func uploadNotSyncedData() {
        print("🔄 Checking for uploads …")
        guard !isSyncing else {
            print("🔄 … sync in progress")
            return
        }
        
        Task {
            do {
                let queue = try getUploadQueue()
                guard !queue.isEmpty else {
                    print("🔄 … nothing to upload")
                    return
                }
                print("🔄 … upload queue has \(queue.userFoods.count) userFoods, \(queue.jsonIds.count) jsons, \(queue.imageIds.count) imageIds")
                print("🔄     Stopping monitoring, setting isSyncing to true, and beginning upload")
                stopMonitoring()
                isSyncing = true
                try await upload(queue)
                print("🔄     Setting isSyncing to false, and starting monitoring again")
                isSyncing = false
                startMonitoring()
            } catch {
                print("⚠️ Error during sync: \(error)")
                isSyncing = false
                startMonitoring()
            }
        }
    }
    
    func upload(_ queue: UploadQueue) async throws {
        return try await withThrowingTaskGroup(of: Result<UploadStep, UploadError>.self) { group in
            
            group.addTask {
                return try await self.uploadUserFoods(queue.userFoods)
            }

            for imageId in queue.imageIds {
                group.addTask {
                    return try await self.uploadImage(with: imageId)
                }
            }

            for jsonId in queue.jsonIds {
                group.addTask {
                    return try await self.uploadJson(with: jsonId)
                }
            }

            let start = CFAbsoluteTimeGetCurrent()
            
            for try await result in group {
                switch result {
                case .success(let step):
                    print("⏫ Upload Step: \(step) completed in \(CFAbsoluteTimeGetCurrent()-start)s")
                case .failure(let error):
                    throw error
                }
            }
            
            print("✅ Upload completed in \(CFAbsoluteTimeGetCurrent()-start)s")
        }
    }
}

public func sleepTask(_ seconds: Double, tolerance: Double = 1) async throws {
    try await Task.sleep(
        until: .now + .seconds(seconds),
        tolerance: .seconds(tolerance),
        clock: .suspending
    )
}
