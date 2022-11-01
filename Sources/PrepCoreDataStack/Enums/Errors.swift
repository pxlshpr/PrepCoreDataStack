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

enum CoreDataManagerError: Error {
    case mismatchingUserFoodEntities
    case duplicateImageFileEntities
    case missingImageFileEntity
    case multipleUserFoodsForTheSameId
    case missingUserFoodEntity
    
    case saveInChangeSyncStatusOfUserFoods(Error)
    case saveInChangeSyncStatusOfImage(Error)
    case saveInChangeSyncStatusOfJson(Error)

    case fetchUserFoods(Error)
    case fetchImageFile(Error)
    case fetchUserFoodForJson(Error)
    
    case couldNotFindCurrentUser
}
