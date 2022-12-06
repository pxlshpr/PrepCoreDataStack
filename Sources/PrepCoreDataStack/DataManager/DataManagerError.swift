import Foundation

enum DataManagerError: Error {
    case noUserFound
    case noDayFoundWhenInsertingMealFromServer
    
    case mealNotFound
}
