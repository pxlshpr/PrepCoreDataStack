import Foundation

public enum DataManagerError: Error {
    case userExists
    case noUserFound
    case noDayFoundWhenInsertingMealFromServer
    
    case mealNotFound
}
