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

    func createDayEntity(on date: Date, for userId: UUID) throws -> DayEntity {
        let dayEntity = DayEntity(context: viewContext, date: date, userId: userId)
        self.viewContext.insert(dayEntity)
        return dayEntity
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
}
