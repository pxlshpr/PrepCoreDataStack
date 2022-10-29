import Foundation
import PrepDataTypes
import UIKit

enum FoodSaveError: Error {
    case unhandledError(FoodSaveStep)
    case persistImageError(UUID, Error? = nil)
    case persistJSONError(Error? = nil)
}

enum FileManagerError: Error {
    case unableToGetUrl
    case unableToCreateDirectory
}

enum ImageError: Error {
    case unableToGetData
    case unableToResize
}

extension FoodFormManager {
    
    
    var documentsUrl: URL? { FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first }
    var imagesUrl: URL? { documentsUrl?.appending(component: "images") }
    var jsonsUrl: URL? { documentsUrl?.appending(component: "jsons") }
    
    func url(at folderUrl: URL?, for uuid: UUID, ext: String) throws -> URL? {
        guard let folderUrl else { throw FileManagerError.unableToGetUrl }
        do {
            try createDirectoryIfNeeded(at: folderUrl)
        } catch {
            throw FileManagerError.unableToCreateDirectory
        }
        return folderUrl.appending(component: "\(uuid.uuidString).\(ext)")
    }
    
    func jsonUrl(for uuid: UUID) throws -> URL? {
        try url(at: jsonsUrl, for: uuid, ext: "json")
    }
    
    func imageUrl(for uuid: UUID) throws -> URL? {
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
    
    func persistImage(_ image: UIImage, with uuid: UUID) async -> Result<FoodSaveStep, FoodSaveError> {
        do {
            guard let imageUrl = try imageUrl(for: uuid) else {
                return .failure(.persistImageError(uuid))
            }
            guard let imageData = try image.getImageData() else {
                return .failure(.persistImageError(uuid, ImageError.unableToGetData))
            }
            try imageData.write(to: imageUrl)
            print("Wrote image to: \(imageUrl.absoluteURL)")
            return Result.success(.persistImage(uuid))
        } catch {
            return .failure(.persistImageError(uuid, error))
        }
    }
    
    func persistJSONData(_ jsonData: Data, for uuid: UUID) async -> Result<FoodSaveStep, FoodSaveError> {
        do {
            guard let jsonUrl = try jsonUrl(for: uuid) else {
                return .failure(.persistJSONError())
            }
            try jsonData.write(to: jsonUrl)
            print("Wrote json to: \(jsonUrl.absoluteURL)")
            return Result.success(.persistJSON)
        } catch {
            return .failure(.persistJSONError(error))
        }
    }
    
}

extension UIImage {
    func getImageData() throws -> Data? {
        guard let resized = resizeImage(image: self, targetSize: CGSize(width: 2048, height: 2048)) else {
            throw ImageError.unableToResize
        }
        return resized.jpegData(compressionQuality: 0.8)
    }
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
