import Foundation
import PrepDataTypes

extension FoodFormManager {
    func saveImageFileEntity(for uuid: UUID) throws {
        let imageFile = ImageFile(id: uuid, syncStatus: .notSynced)
        try DataManager.shared.addNewImageFile(imageFile)
        print("💾 Created ImageFileEntity for \(uuid.uuidString)")
    }

    func saveJSONFileEntity(for uuid: UUID) throws {
        let jsonFile = JSONFile(id: uuid, syncStatus: .notSynced)
        try DataManager.shared.addNewJSONFile(jsonFile)
        print("💾 Created JSONFileEntity for \(uuid.uuidString)")
    }

}
