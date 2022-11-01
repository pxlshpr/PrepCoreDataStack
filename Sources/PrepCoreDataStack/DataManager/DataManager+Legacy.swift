//import Foundation
//import CoreData
//
//public class DataManager: ObservableObject {
//
//    public static let shared = DataManager()
//
//    let coreDataManager: CoreDataManager
//
////    @Published private(set) public var recents: [UserFood] = []
//
//    convenience init() {
//        self.init(coreDataManager: CoreDataManager())
//    }
//
//    init(coreDataManager: CoreDataManager) {
//        self.coreDataManager = coreDataManager
////        Task {
////            self.recents = try await coreDataManager.recentUserFoods().map { UserFood(from: $0) }
////        }
//
////        do {
////            self.recents = try coreDataManager.recentUserFoods().map { UserFood(from: $0) }
////        } catch {
////            print("Error: \(error)")
////        }
//
////        do {
////            self.userFoods = try await self.coreDataManager.userFoods().map {
////                return UserFood(from: $0)
////            }
////            self.imageFiles = try self.coreDataManager.imageFiles().map {
////                return ImageFile(from: $0)
////            }
////        } catch {
////            self.userFoods = []
////            self.imageFiles = []
////        }
//    }
//
//    func refresh() {
////        do {
////            coreDataManager.viewContext.reset()
////            recents = try coreDataManager.recentUserFoods().map { UserFood(from: $0) }
////        } catch {
////            print("Error refreshing")
////        }
//    }
//
////    public func save(userFood: UserFood) throws {
////        let entity = UserFoodEntity(context: coreDataManager.viewContext, userFood: userFood)
////        try self.coreDataManager.saveUserFood(entity: entity, context: coreDataManager.viewContext)
////        try await coreDataManager.performBackgroundTask { backgroundContext in
////            let entity = UserFoodEntity(context: backgroundContext, userFood: userFood)
////            try self.coreDataManager.saveUserFood(entity: entity, context: backgroundContext)
//////            try await self.refresh()
////        }
//////        await coreDataManager.performBackgroundTask { backgroundContext in
//////            Task {
//////                let entity = UserFoodEntity(context: backgroundContext, userFood: userFood)
//////                try self.coreDataManager.saveUserFood(entity: entity, context: backgroundContext)
//////                try await self.refresh()
//////            }
//////        }
////    }
////
////    public func save(imageFile: ImageFile) async throws {
////        let entity = ImageFileEntity(context: self.coreDataManager.viewContext, imageFile: imageFile)
////        try self.coreDataManager.saveImageFile(entity: entity)
////        try await refresh()
////    }
////
////    public func refresh() async throws {
////        let userFoods = try await self.coreDataManager.userFoods().map {
////            return UserFood(from: $0)
////        }
////        let imageFiles = try self.coreDataManager.imageFiles().map {
////            return ImageFile(from: $0)
////        }
////        DispatchQueue.main.async {
////            self.userFoods = userFoods
////            self.imageFiles = imageFiles
////        }
////    }
////
////    func userFoodsToSync() async throws -> [UserFood] {
////        try await coreDataManager.userFoodsToSync().map{ UserFood(from: $0) }
////    }
////
////    func imageFilesToSync() async throws -> [ImageFile] {
////        try await coreDataManager.imageFilesToSync().map{ ImageFile(from: $0) }
////    }
////
////    func userFoodsWithJsonToSync() async throws -> [UserFood] {
////        try await coreDataManager.userFoodsWithJsonToSync().map{ UserFood(from: $0) }
////    }
////
////    func changeSyncStatus(ofUserFoods userFoods: [UserFood], to syncStatus: SyncStatus) throws {
////        try coreDataManager.changeSyncStatus(ofUserFoods: userFoods, to: syncStatus)
////    }
////
////    func changeSyncStatus(ofImageWith id: UUID, to syncStatus: SyncStatus) throws {
////        try coreDataManager.changeSyncStatus(ofImageWith: id, to: syncStatus)
////    }
////
////    func changeSyncStatus(ofJsonWith id: UUID, to syncStatus: SyncStatus) throws {
////        try coreDataManager.changeSyncStatus(ofJsonWith: id, to: syncStatus)
////    }
//}
