import CoreData

/// Day
extension CoreDataManager {
    func fetchOrCreateDayEntity(for date: Date) throws -> DayEntity {
        try fetchDayEntity(for: date, context: viewContext) ?? (try createDayEntity(for: date))
    }

    func fetchDayEntity(for date: Date, context: NSManagedObjectContext) throws -> DayEntity? {
        let request: NSFetchRequest<DayEntity> = DayEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %f", date.startOfDay.timestamp)
        return try context.fetch(request).first
    }

    func createDayEntity(for date: Date) throws -> DayEntity {
        let dayEntity = DayEntity(context: viewContext, date: date)
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
    
    func saveMealEntity(named name: String, at time: Date, on date: Date) throws -> MealEntity {
        let dayEntity = try fetchOrCreateDayEntity(for: date)
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
