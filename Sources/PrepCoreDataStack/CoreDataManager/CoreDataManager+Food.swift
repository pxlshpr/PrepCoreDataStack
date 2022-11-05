import Foundation
import CoreData

extension CoreDataManager {

    func saveImageFileEntity(_ entity: ImageFileEntity) throws {
        viewContext.insert(entity)
        try viewContext.save()
    }

    func saveJSONFileEntity(_ entity: JSONFileEntity) throws {
        viewContext.insert(entity)
        try viewContext.save()
    }

    func insertFoodEntity(_ entity: FoodEntity) {
        viewContext.insert(entity)
    }

    func insertBarcodeEntity(_ entity: BarcodeEntity) {
        viewContext.insert(entity)
    }    
}


extension CoreDataManager {
    func fetchMyFoodEntities(context: NSManagedObjectContext) throws -> [FoodEntity] {
        let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
        //TODO: Predicate to only include user's foods (we may have presets or other user foods saved)
//        request.predicate = NSPredicate(format: "calendarDayString IN %@", range.calendarDayStrings)
        return try context.fetch(request)
    }
}
extension CoreDataManager {
    func myFoodEntities(completion: @escaping (([FoodEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {
                do {
                    let foods = try self.fetchMyFoodEntities(context: bgContext)
                    completion(foods)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }
}
