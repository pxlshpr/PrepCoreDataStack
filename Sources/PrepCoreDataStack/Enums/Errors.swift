import Foundation

enum FoodSaveError: Error {
    case persistImageError(UUID, Error? = nil)
    case persistJSONError(Error? = nil)
    case saveImageFileEntityError(Error)
    case saveUserFoodEntityError(Error)
}

enum FileManagerError: Error {
    case unableToGetUrl
    case unableToCreateDirectory
}

enum ImageError: Error {
    case unableToGetData
    case unableToResize
}
