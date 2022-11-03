import PrepDataTypes

extension DayMeal {
    public init(from entity: MealEntity) {
        self.init(
            id: entity.id!,
            name: entity.name!,
            time: entity.time,
            markedAsEatenAt: entity.markedAsEatenAt,
            foodItems: []
        )
    }
}
