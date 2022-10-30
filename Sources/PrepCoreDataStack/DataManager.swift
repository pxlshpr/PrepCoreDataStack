import Foundation
import CoreData

public class DataManager: ObservableObject {
    
    public static let shared = DataManager()
    
    let coreDataManager: CoreDataManager
    
    @Published private(set) public var userFoods: [UserFood]
    @Published private(set) public var imageFiles: [ImageFile]

    convenience init() {
        self.init(coreDataManager: CoreDataManager())
    }
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        do {
            self.userFoods = try self.coreDataManager.userFoods().map {
                return UserFood(from: $0)
            }
            self.imageFiles = try self.coreDataManager.imageFiles().map {
                return ImageFile(from: $0)
            }
        } catch {
            self.userFoods = []
            self.imageFiles = []
        }
    }
    
    public func save(userFood: UserFood) throws {
        let entity = UserFoodEntity(context: self.coreDataManager.viewContext, userFood: userFood)
        try self.coreDataManager.saveUserFood(entity: entity)
        try refresh()
    }

    public func save(imageFile: ImageFile) throws {
        let entity = ImageFileEntity(context: self.coreDataManager.viewContext, imageFile: imageFile)
        try self.coreDataManager.saveImageFile(entity: entity)
        try refresh()
    }

    public func refresh() throws {
        let userFoods = try self.coreDataManager.userFoods().map {
            return UserFood(from: $0)
        }
        let imageFiles = try self.coreDataManager.imageFiles().map {
            return ImageFile(from: $0)
        }
        DispatchQueue.main.async {
            self.userFoods = userFoods
            self.imageFiles = imageFiles
        }
    }
    
    func userFoodsToSync() throws -> [UserFood] {
        try coreDataManager.userFoodsToSync().map{ UserFood(from: $0) }
    }
    
    func imageFilesToSync() throws -> [ImageFile] {
        try coreDataManager.imageFilesToSync().map{ ImageFile(from: $0) }
    }
    
    func userFoodsWithJsonToSync() throws -> [UserFood] {
        try coreDataManager.userFoodsWithJsonToSync().map{ UserFood(from: $0) }
    }
    
    func changeSyncStatus(ofUserFoods userFoods: [UserFood], to syncStatus: SyncStatus) throws {
        try coreDataManager.changeSyncStatus(ofUserFoods: userFoods, to: syncStatus)
    }
    
    func changeSyncStatus(ofImageWith id: UUID, to syncStatus: SyncStatus) throws {
        try coreDataManager.changeSyncStatus(ofImageWith: id, to: syncStatus)
    }

    func changeSyncStatus(ofJsonWith id: UUID, to syncStatus: SyncStatus) throws {
        try coreDataManager.changeSyncStatus(ofJsonWith: id, to: syncStatus)
    }
}
