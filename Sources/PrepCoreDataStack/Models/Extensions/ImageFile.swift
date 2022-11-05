import Foundation
import PrepDataTypes

public struct ImageFile: Identifiable {
    public var id: UUID
    public var syncStatus: SyncStatus
}

//MARK: ImageFileEntity → ImageFile
public extension ImageFile {
    init(from entity: ImageFileEntity) {
        self.id = entity.id!
        self.syncStatus = SyncStatus(rawValue: entity.syncStatus)!
    }
}

public extension ImageFile {
    func getUrl() throws -> URL {
        try imageUrl(for: id)
    }
}
