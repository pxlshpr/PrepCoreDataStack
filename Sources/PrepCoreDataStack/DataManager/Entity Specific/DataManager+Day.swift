import Foundation
import PrepDataTypes

public extension DataManager {
    
    func getDay(for date: Date) async throws -> Day? {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.dayEntity(for: date) { dayEntity in
                    guard let dayEntity else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let day = Day(from: dayEntity)
                    continuation.resume(returning: day)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func days(for range: Range<Date>) async throws -> [Day] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.dayEntities(for: range) { dayEntities in
                    let days = dayEntities.map { Day(from: $0) }
                    continuation.resume(returning: days)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
