import CoreData
import PrepDataTypes

/// Day
extension CoreDataManager {
    func fetchOrCreateDayEntity(on date: Date, for userId: UUID) throws -> DayEntity {
        try fetchDayEntity(for: date, context: viewContext) ?? (try createDayEntity(on: date, for: userId))
    }

    func fetchDayEntity(calendarDayString: String, context: NSManagedObjectContext) throws -> DayEntity? {
        let request: NSFetchRequest<DayEntity> = DayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "calendarDayString == %@", calendarDayString)
        return try context.fetch(request).first
    }

    func fetchDayEntity(for date: Date, context: NSManagedObjectContext) throws -> DayEntity? {
        try fetchDayEntity(calendarDayString: date.calendarDayString, context: context)
    }

    func fetchDayEntities(for range: Range<Date>, context: NSManagedObjectContext) throws -> [DayEntity] {
        let request: NSFetchRequest<DayEntity> = DayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "calendarDayString IN %@", range.calendarDayStrings)
        return try context.fetch(request)
    }

    func createDayEntity(on date: Date, for userId: UUID) throws -> DayEntity {
        let dayEntity = DayEntity(context: viewContext, date: date, userId: userId)
        
        if let lastGoalSetEntity = try lastUsedDayGoalSetEntity(context: viewContext) {
            dayEntity.goalSet = lastGoalSetEntity
        }
        
        self.viewContext.insert(dayEntity)
        return dayEntity
    }
}

extension DataManager {
    public func badgeWidths(on date: Date, completion: @escaping (([UUID : CGFloat]) -> ())) {
        coreDataManager.badgeWidths(on: date, completion: completion)
    }
}

extension CoreDataManager {
    public func badgeWidths(on date: Date, completion: @escaping (([UUID : CGFloat]) -> ())) {
        Task {
            let bgContext = newBackgroundContext()
            await bgContext.perform {
                do {
                    
                    var badgeWidths: [UUID : CGFloat] = [:]
                    guard let dayEntity = try self.fetchDayEntity(for: date, context: bgContext) else {
                        completion([:])
                        return
                    }
                    
                    for mealEntity in dayEntity.mealEntities {
                        
                        /// Add `badgeWidth` for meal itself
                        badgeWidths[mealEntity.id!] = mealEntity.badgeWidth
                        
                        /// Add `badgeWidth` for all food items
                        for foodItemEntity in mealEntity.nonDeletedFoodItemEntities {
                            badgeWidths[foodItemEntity.id!] = foodItemEntity.badgeWidth
                        }
                    }
                    
                    completion(badgeWidths)
                    
                } catch {
                    print("Error: \(error)")
                    completion([:])
                }
            }
        }
    }
}

extension CoreDataManager {

    func dayEntity(for date: Date, completion: @escaping ((DayEntity?) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    guard let day = try self.fetchDayEntity(for: date, context: bgContext) else {
                        completion(nil)
                        return
                    }
                    completion(day)
//                    let meals = day.meals?.allObjects as? [MealEntity] ?? []
//                    completion(meals)
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    func dayEntities(for range: Range<Date>, completion: @escaping (([DayEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    let days = try self.fetchDayEntities(for: range, context: bgContext)
                    completion(days)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }
    
    /// Returns true if a `Day` was found and updated
    func updateDate(_ date: Date, with bodyProfile: BodyProfile) throws -> Bool {
        
        guard let dayEntity = try fetchDayEntity(for: date, context: viewContext) else {
            return false
        }
        
        dayEntity.bodyProfile = try! JSONEncoder().encode(bodyProfile)
        dayEntity.syncStatus = SyncStatus.notSynced.rawValue
        dayEntity.updatedAt = Date().timeIntervalSince1970

        try self.viewContext.save()
        
        return true
    }
}
