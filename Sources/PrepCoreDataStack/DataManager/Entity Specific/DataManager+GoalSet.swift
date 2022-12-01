import Foundation
import PrepDataTypes

public extension DataManager {
    
    func addGoalSetAndBodyProfile(_ goalSet: GoalSet, bodyProfile: BodyProfile?) {
        do {
            if let bodyProfile {
                try DataManager.shared.setBodyProfile(bodyProfile)
            }
            try DataManager.shared.addNewGoalSet(goalSet)
        } catch {
            print("Error adding or setting goal set")
        }
    }
    
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

public extension DataManager {
    /// Sets `GoalSet` on provided date and returns `Day` in case we created one
    func setGoalSet(_ goalSet: GoalSet, on date: Date) throws -> Day {
        guard let user else { throw DataManagerError.noUserFound }
        let dayEntity = try coreDataManager.setGoalSet(goalSet, on: date, for: user.id)
        return Day(from: dayEntity)
    }
    
    func removeGoalSet(on date: Date) throws {
        try coreDataManager.removeGoalSet(on: date)
    }
}

public extension DataManager {
    var diets: [GoalSet] {
        goalSets.filter { $0.type == .day }
    }
    
    var mealTypes: [GoalSet] {
        goalSets.filter { $0.type == .meal }
    }
    
    func goalSets(for type: GoalSetType) -> [GoalSet] {
        goalSets.filter { $0.type == type }
    }
}
