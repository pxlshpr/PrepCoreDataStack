import Foundation
import PrepDataTypes
import CoreData

//MARK: Day → DayEntity
extension DayEntity {
    convenience init(context: NSManagedObjectContext, day: Day) {
        self.init(context: context)
        self.id = day.id
        self.calendarDayString = day.calendarDayString
        self.bodyProfile = try! JSONEncoder().encode(day.bodyProfile)
        self.updatedAt = day.updatedAt
        self.syncStatus = day.syncStatus.rawValue
    }
    
    convenience init(context: NSManagedObjectContext, date: Date, userId: UUID) {
        self.init(context: context)
        self.id = "\(userId.uuidString.lowercased())_\(Int(date.startOfDay.timeIntervalSince1970))"
        self.calendarDayString = date.calendarDayString
                
        self.updatedAt = Date().timeIntervalSince1970
        self.syncStatus = SyncStatus.notSynced.rawValue
    }
}

extension DayEntity {
    func update(with serverDay: Day, in context: NSManagedObjectContext) throws {
        id = serverDay.id
        updatedAt = serverDay.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
}

extension DayEntity {
    
    var mealEntities: [MealEntity] {
        meals?.allObjects as? [MealEntity] ?? []
    }
    
    var dayMeals: [DayMeal] {
        mealEntities
            .map { DayMeal(from: $0) }
            .sorted { (lhs, rhs) in
                if lhs.time == rhs.time {
                    return lhs.id.uuidString < rhs.id.uuidString
                }
                return lhs.time < rhs.time
            }
    }
}
