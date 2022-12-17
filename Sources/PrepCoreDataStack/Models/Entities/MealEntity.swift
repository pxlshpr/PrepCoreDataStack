import Foundation
import PrepDataTypes
import CoreData

//MARK: Meal → MealEntity
extension MealEntity {
    convenience init(context: NSManagedObjectContext, meal: Meal, dayEntity: DayEntity, goalSetEntity: GoalSetEntity?) {
        self.init(context: context)
        self.id = meal.id
        self.day = dayEntity
        self.name = meal.name
        self.time = meal.time
        self.markedAsEatenAt = meal.markedAsEatenAt ?? 0
        self.goalSet = goalSetEntity
        self.goalWorkoutMinutes = Int32(meal.goalWorkoutMinutes ?? 0)
        self.updatedAt = meal.updatedAt
        self.deletedAt = meal.deletedAt ?? 0
        self.syncStatus = meal.syncStatus.rawValue
    }
    
    convenience init(
        context: NSManagedObjectContext,
        name: String,
        time: Date,
        dayEntity: DayEntity,
        goalSetEntity: GoalSetEntity?
    ) {
        self.init(context: context)
        self.id = UUID()
        self.name = name
        self.time = time.timeIntervalSince1970
        self.markedAsEatenAt = 0
        self.goalSet = goalSetEntity
        self.goalWorkoutMinutes = 0
        self.updatedAt = Date().timeIntervalSince1970
        self.deletedAt = 0
        self.day = dayEntity
        self.syncStatus = SyncStatus.notSynced.rawValue
    }
}

extension MealEntity {
    func update(with serverMeal: Meal, goalSetEntity: GoalSetEntity?, in context: NSManagedObjectContext) throws {
        id = serverMeal.id
        name = serverMeal.name
        time = serverMeal.time
        markedAsEatenAt = serverMeal.markedAsEatenAt ?? 0
        goalSet = goalSetEntity
        goalWorkoutMinutes = Int32(serverMeal.goalWorkoutMinutes ?? 0)
        updatedAt = serverMeal.updatedAt
        syncStatus = SyncStatus.synced.rawValue
    }
}

extension MealEntity {
    var foodItemEntities: [FoodItemEntity] {
        foodItems?.allObjects as? [FoodItemEntity] ?? []
    }
    
    var mealFoodItems: [MealFoodItem] {
        foodItemEntities
            .map { MealFoodItem(from: $0) }
            .sorted { (lhs, rhs) in
                return lhs.sortPosition < rhs.sortPosition
            }
    }
}

//MARK: Move this elsewhere
extension MealFoodItem {
    public init(from entity: FoodItemEntity) {
        self.init(
            id: entity.id!,
            food: Food(from: entity.food!),
            amount: try! JSONDecoder().decode(FoodValue.self, from: entity.amount!),
            markedAsEatenAt: entity.markedAsEatenAt,
            sortPosition: Int(entity.sortPosition),
            isSoftDeleted: entity.deletedAt > 0,
//            macrosIndicatorWidth: entity.macrosIndicatorWidth
            macrosIndicatorWidth: 0
        )
    }
}
