import Foundation
import PrepDataTypes
import CoreData

//MARK: Day → DayEntity
extension DayEntity {
    convenience init(context: NSManagedObjectContext, day: Day, goalSetEntity: GoalSetEntity?) {
        self.init(context: context)
        self.id = day.id
        self.calendarDayString = day.calendarDayString
        self.goalSet = goalSetEntity
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
    func update(
        with serverDay: Day,
        goalSetEntity: GoalSetEntity?,
        in context: NSManagedObjectContext
    ) throws {
        
        goalSet = goalSetEntity
        bodyProfile = try! JSONEncoder().encode(serverDay.bodyProfile)

        updatedAt = serverDay.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
}

extension DayEntity {
    
    var allMealEntitiesIncludingSoftDeleted: [MealEntity] {
        meals?.allObjects as? [MealEntity] ?? []
    }

    /// Include only those that haven't been soft-deleted
    var mealEntities: [MealEntity] {
        allMealEntitiesIncludingSoftDeleted
            .filter({ $0.deletedAt == 0 })
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
