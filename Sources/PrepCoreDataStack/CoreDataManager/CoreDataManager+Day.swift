import CoreData

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
        self.viewContext.insert(dayEntity)
        return dayEntity
    }
}

extension Range where Bound == Date {
    var dates: [Date] {
        Array(stride(
            from: lowerBound.startOfDay,
            to: upperBound.startOfDay,
            by: 60*60*24
        ))
    }
    
    var calendarDayStrings: [String] {
        dates.map { $0.calendarDayString }
    }
}
/// Meal
extension CoreDataManager {
//    func saveNewMeal(named name: String, at time: Date, on date: Date) throws -> (MealEntity, DayEntity) {
//        let dayEntity = try fetchOrCreateDayEntity(for: date)
//        let mealEntity =
//    }
    
    func saveMealEntity(named name: String, at time: Date, on date: Date, for userId: UUID) throws -> MealEntity {
        let dayEntity = try fetchOrCreateDayEntity(on: date, for: userId)
        let mealEntity = MealEntity(
            context: viewContext,
            name: name,
            time: time,
            dayEntity: dayEntity
        )
        self.viewContext.insert(mealEntity)
        try self.viewContext.save()
        return mealEntity
    }
    
    func mealEntities(for date: Date, completion: @escaping (([MealEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {

                do {
                    guard let day = try self.fetchDayEntity(for: date, context: bgContext) else {
                        completion([])
                        return
                    }
                    let meals = day.meals?.allObjects as? [MealEntity] ?? []
                    completion(meals)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }
    
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
}
