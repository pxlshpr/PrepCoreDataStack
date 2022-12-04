import Foundation
import PrepDataTypes

public extension DataManager {
    
    /// Get a `Day` for a provided `Date` on the main thread.
    func day(for date: Date) throws -> Day? {
        guard let dayEntity = try coreDataManager.fetchDayEntity(for: date, context: coreDataManager.viewContext) else {
            return nil
        }
        return Day(from: dayEntity)
    }
    
    /// Get a `Day` for a provided `Date` asynchronously—so keep thread safety in mind when using this.
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
