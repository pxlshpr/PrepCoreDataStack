import Foundation
import PrepDataTypes

public extension DataManager {
    
    func addNewGoalSet(_ goalSet: GoalSet) throws {
        
        /// Construct the new `GoalSetEntity` and insert it
        let entity = GoalSetEntity(context: coreDataManager.viewContext, goalSet: goalSet)
        coreDataManager.insertGoalSetEntity(entity)

        try coreDataManager.save()
        
        //TODO: Revisit this sending a notification shebang
//        /// Send a notification named`didAddFood` with the new `Food`
//        let food = Food(from: foodEntity)
//        NotificationCenter.default.post(
//            name: .didAddFood,
//            object: nil,
//            userInfo: [
//                Notification.Keys.food: food
//            ]
//        )

        /// Add the new goal set to the locally stored array
        self.goalSets.append(goalSet)
    }
}

public extension DataManager {
    func loadGoalSets() {
        Task {
            let goalSets = try await getGoalSets()
            await MainActor.run {
                self.goalSets = goalSets
            }
        }
    }
    
    func getGoalSets() async throws -> [GoalSet] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.goalSetEntities() { goalSetEntities in
                    let goalSets = goalSetEntities.map { GoalSet(from: $0) }
                    continuation.resume(returning: goalSets)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
