import Foundation
import PrepDataTypes

public extension DataManager {

    func setBodyProfile(_ bodyProfile: BodyProfile) throws {
        
        ///     update `User` with it
        try setUserTDEEProfile(bodyProfile)
        
        ///     update current `Day` with it if it exists
    }
}

public extension DataManager {
    func getCurrentBodyProfile() async throws -> BodyProfile? {
        nil
//        try await withCheckedThrowingContinuation { continuation in
//            do {
//                try coreDataManager.myFoodEntities() { foodEntities in
//                    let foods = foodEntities.map { Food(from: $0) }
//                    continuation.resume(returning: foods)
//                }
//            } catch {
//                continuation.resume(throwing: error)
//            }
//        }
    }
}
