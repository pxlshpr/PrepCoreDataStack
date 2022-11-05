import Foundation
import PrepDataTypes

public struct JSONFile: Identifiable {
    public var id: UUID
    public var syncStatus: SyncStatus
}

//MARK: JSONFileEntity → JSONFile
public extension JSONFile {
    init(from entity: JSONFileEntity) {
        self.id = entity.id!
        self.syncStatus = SyncStatus(rawValue: entity.syncStatus)!
    }
}

public extension JSONFile {
    func getUrl() throws -> URL {
        try jsonUrl(for: id)
    }
}
