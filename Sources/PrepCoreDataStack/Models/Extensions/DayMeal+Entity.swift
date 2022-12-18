import PrepDataTypes
import Foundation

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
            foodItems: entity.mealFoodItems,
//            macrosIndicatorWidth: entity.macrosIndicatorWidth
            macrosIndicatorWidth: 0
        )
    }
}

extension DayEntity {
    var foodItemEntities: [FoodItemEntity] {
        var entities: [FoodItemEntity] = []
        for mealEntity in mealEntities {
            entities.append(contentsOf: mealEntity.nonDeletedFoodItemEntities)
        }
        return entities
    }
    
    var foodItemEnergyValuesInKcalDecreasing: [Double] {
        foodItemEntities
            .filter { $0.scaledValueForEnergyInKcal > 0 }
            .map { $0.scaledValueForEnergyInKcal }
            .sorted { $0 > $1 }
    }

    var largestFoodItemEnergyInKcal: Double {
        foodItemEnergyValuesInKcalDecreasing.first ?? 0
    }
    
    var smallestFoodItemEnergyInKcal: Double {
        foodItemEnergyValuesInKcalDecreasing.last ?? 0
    }

    var mealEnergyValuesInKcalDecreasing: [Double] {
        mealEntities
            .filter { !$0.nonDeletedFoodItemEntities.isEmpty }
            .map { $0.energyValueInKcal }
            .sorted { $0 > $1 }
    }
    
    var largestMealEnergyInKcal: Double {
        mealEnergyValuesInKcalDecreasing.first ?? 0
    }
    
    var smallestMealEnergyInKcal: Double {
        mealEnergyValuesInKcalDecreasing.last ?? 0
    }

    func macrosIndicatorWidth(for energyInKcal: CGFloat) -> CGFloat {
        calculateMacrosIndicatorWidth(
            for: energyInKcal,
            largest: largestMealEnergyInKcal,
            smallest: smallestMealEnergyInKcal
        )
    }
}

extension MealEntity {
    
    var badgeWidth: CGFloat {
        day?.macrosIndicatorWidth(for: energyValueInKcal) ?? 0
    }
    
    var energyValueInKcal: Double {
        foodItemEntities.reduce(0) {
            $0 + $1.scaledValueForEnergyInKcal
        }
    }
}

extension FoodItemEntity {
    
    var badgeWidth: CGFloat {
        guard let dayEntity = meal?.day else {
            return 0
        }
        
        return calculateMacrosIndicatorWidth(
            for: scaledValueForEnergyInKcal,
            largest: dayEntity.largestFoodItemEnergyInKcal,
            smallest: dayEntity.smallestFoodItemEnergyInKcal
        )
    }
    
    var scaledValueForEnergyInKcal: Double {
        guard let food, let amount else { return 0 }
        let foodObject = Food(from: food)
        
        guard let amount = try? JSONDecoder().decode(FoodValue.self, from: amount) else {
            fatalError("Couldn't decode amount")
        }
        
        guard let foodQuantity = foodObject.quantity(for: amount) else { return 0 }
        let scaleFactor = foodObject.nutrientScaleFactor(for: foodQuantity) ?? 0
        
        return foodObject.info.nutrients.energyInKcal * scaleFactor
    }
}
