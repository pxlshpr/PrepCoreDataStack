import Foundation
import CoreData

extension CoreDataManager {
    func insertGoalSetEntity(_ entity: GoalSetEntity) {
        viewContext.insert(entity)
    }
}

extension CoreDataManager {
    func fetchGoalSetEntities(context: NSManagedObjectContext) throws -> [GoalSetEntity] {
        let request: NSFetchRequest<GoalSetEntity> = GoalSetEntity.fetchRequest()
        return try context.fetch(request)
    }
}
extension CoreDataManager {
    func goalSetEntities(completion: @escaping (([GoalSetEntity]) -> ())) throws {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {
                do {
                    let entities = try self.fetchGoalSetEntities(context: bgContext)
                    completion(entities)
                } catch {
                    print("Error: \(error)")
                    completion([])
                }
            }
        }
    }
}
