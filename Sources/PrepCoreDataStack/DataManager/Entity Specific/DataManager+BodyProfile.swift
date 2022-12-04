import Foundation
import PrepDataTypes

public extension DataManager {

    func setBodyProfile(_ bodyProfile: BodyProfile) throws {
        /// update `User` with it
        try setUserTDEEProfile(bodyProfile)
        
        try updateTodayWithBodyProfile(bodyProfile)
    }
    
    /**
     Updates today's `Day` object (and yesterday if there's no `BodyProfile`—in case we're in the wee hours (12am-6am) and are logging meals for 'yesterday' technically).
     
     This is not reliant on, and does not effect the current day we be viewing the `Diary`, as we currently only care about setting `BodyProfile`s for today.
     */
    func updateTodayWithBodyProfile(_ bodyProfile: BodyProfile) throws {
        
        func sendNotification(for date: Date) {
            let userInfo: [String : Any] = [
                Notification.Keys.date: date,
                Notification.Keys.bodyProfile: bodyProfile
            ]
            
            NotificationCenter.default.post(
                name: .didUpdateDayWithBodyProfile, object: nil,
                userInfo: userInfo
            )
        }
        
        let date = Date()
        if try coreDataManager.updateDate(date, with: bodyProfile) {
            sendNotification(for: date)
        }
        if date.isInWeeHours, try coreDataManager.updateDate(date.moveDayBy(-1), with: bodyProfile) {
            sendNotification(for: date.moveDayBy(-1))
        }
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
