import PrepDataTypes

extension DayMeal {
    public init(from entity: MealEntity) {
        
        let goalSet: GoalSet?
        if let goalSetEntity = entity.goalSet {
            goalSet = GoalSet(from: goalSetEntity)
        } else {
            goalSet = nil
        }
        
        self.init(
            id: entity.id!,
            name: entity.name!,
            time: entity.time,
            markedAsEatenAt: entity.markedAsEatenAt,
            goalSet: goalSet,
            foodItems: entity.mealFoodItems
        )
    }
}
