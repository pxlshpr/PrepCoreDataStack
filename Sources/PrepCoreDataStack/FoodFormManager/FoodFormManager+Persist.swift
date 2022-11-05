import Foundation
import PrepDataTypes
import UIKit

extension FoodFormManager {
    
    func persistImage(_ image: UIImage, with uuid: UUID) async -> Result<FoodSaveStep, FoodSaveError> {
        do {
            let imageUrl = try imageUrl(for: uuid)
            guard let imageData = try image.getImageData() else {
                return .failure(.persistImageError(uuid, ImageError.unableToGetData))
            }
            try imageData.write(to: imageUrl)
            print("📝 Wrote image to: \(imageUrl.absoluteURL)")
            return Result.success(.persistImage(uuid))
        } catch {
            return .failure(.persistImageError(uuid, error))
        }
    }
    
    func persistJSONData(_ jsonData: Data, for uuid: UUID) async -> Result<FoodSaveStep, FoodSaveError> {
        do {
            let jsonUrl = try jsonUrl(for: uuid)
            try jsonData.write(to: jsonUrl)
            print("📝 Wrote json to: \(jsonUrl.absoluteURL)")
            return Result.success(.persistJSON)
        } catch {
            return .failure(.persistJSONError(error))
        }
    }
}

//MARK: - Convenience

//extension FoodFormManager {
    
    var documentsUrl: URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }
    var imagesUrl: URL? { documentsUrl?.appending(component: "images") }
    var jsonsUrl: URL? { documentsUrl?.appending(component: "jsons") }
    
    func url(at folderUrl: URL?, for uuid: UUID, ext: String) throws -> URL {
        guard let folderUrl else { throw FileManagerError.unableToGetUrl }
        do {
            try createDirectoryIfNeeded(at: folderUrl)
        } catch {
            throw FileManagerError.unableToCreateDirectory
        }
        return folderUrl.appending(component: "\(uuid.uuidString).\(ext)")
    }
    
    func jsonUrl(for uuid: UUID) throws -> URL {
        try url(at: jsonsUrl, for: uuid, ext: "json")
    }
    
    func imageUrl(for uuid: UUID) throws -> URL {
        try url(at: imagesUrl, for: uuid, ext: "jpg")
    }
    
    func directoryExists(at url: URL) -> Bool {
        var isDirectory: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: url.absoluteString, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }
    
    func createDirectoryIfNeeded(at url: URL) throws {
        if !directoryExists(at: url) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
//}


//
//func image(imageFilename: String, type: String = "jpg") -> UIImage? {
//
//    return UIImage(contentsOfFile: path)
//}
//
//func sampleMFPProcessedFood(jsonFilename: String) -> MFPProcessedFood? {
//    guard let path = Bundle.main.path(forResource: jsonFilename, ofType: "json") else {
//        return nil
//    }
//
//    do {
//        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//        return mfpProcessedFood
//    } catch {
//        print(error)
//        return nil
//    }
//}
