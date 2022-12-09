import Foundation
import PrepDataTypes
import CoreData

extension DataManager {

    func constructSyncForm() async throws -> SyncForm {
        guard let userId = user?.id else {
            throw SyncError.syncPerformedWithoutFetchedUser
        }
        
        let updates = try await constructSyncUpdates()
        let deletions = try await constructSyncDeletions()
        let form = SyncForm(
            updates: updates,
            deletions: deletions,
            daysLowerBound: daysToSync?.lowerBound.calendarDayString,
            daysUpperBound: daysToSync?.upperBound.calendarDayString,
            userId: userId,
            versionTimestamp: versionTimestamp
        )
        return form
    }

    func constructSyncDeletions() async throws -> SyncForm.Deletions {
        SyncForm.Deletions()
    }
    
    /// Include all entities that have an updatedAt greater than versionTimestamp
    func constructSyncUpdates() async throws -> SyncForm.Updates {
        try await withCheckedThrowingContinuation { continuation in
            coreDataManager.updatedEntities { updatedEntities in
                
                var user: User? = nil
                if let userEntity = updatedEntities.userEntity {
                    user = User(from: userEntity)
                }
                
                var days: [Day]? = nil
                if let dayEntities = updatedEntities.dayEntities {
                    days = dayEntities.map { Day(from: $0) }
                }

                var meals: [Meal]? = nil
                if let mealEntities = updatedEntities.mealEntities {
                    meals = mealEntities.map { Meal(from: $0) }
                }
                
                var foods: [Food]? = nil
                if let foodEntities = updatedEntities.foodEntities {
                    foods = foodEntities.map { Food(from: $0) }
                }
                
                var foodItems: [FoodItem]? = nil
                if let foodItemEntities = updatedEntities.foodItemEntities {
                    foodItems = foodItemEntities.map { FoodItem(from: $0) }
                }

                var goalSets: [GoalSet]? = nil
                if let goalSetEntities = updatedEntities.goalSetEntities {
                    goalSets = goalSetEntities.map { GoalSet(from: $0) }
                }
                
                var fastingActivites: [FastingActivity]? = nil
                if let fastingActivityEntities = updatedEntities.fastingActivityEntities {
                    fastingActivites = fastingActivityEntities.map { FastingActivity(from: $0) }
                }

                let updated = SyncForm.Updates(
                    user: user,
                    days: days,
                    foods: foods,
                    foodItems: foodItems,
                    goalSets: goalSets,
                    meals: meals,
                    fastingActivities: fastingActivites
                )

                continuation.resume(returning: updated)
            }
        }
    }
    
    var updatedUser: User? {
        guard
            let user = user,
            user.updatedAt > versionTimestamp
        else {
            return nil
        }
        return user
    }
}

import CoreData

protocol Fetchable {
    associatedtype FetchableType: NSManagedObject = Self

    static var entityName : String { get }
    static func objects(for predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> [FetchableType]
}

extension Fetchable where Self : NSManagedObject, FetchableType == Self {
    static var entityName : String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    static func objects(for predicate: NSPredicate?, in context: NSManagedObjectContext) throws -> [FetchableType] {
        let request = NSFetchRequest<FetchableType>(entityName: entityName)
        request.predicate = predicate
        return try context.fetch(request)
    }
}

protocol EntityRepresentable {
    associatedtype T: Syncable
    var id: UUID { get }
    static var entityType: T.Type { get }
}

protocol Syncable: NSManagedObject, Fetchable {
    var syncStatus: Int16 { get set }
}


extension Syncable {
    static var entityName : String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension MealEntity: Syncable {
//    static var entityName: String { "MealEntity" }
}

extension FoodEntity: Syncable {
//    static var entityName: String { "FoodEntity" }
}

extension ImageFileEntity: Syncable {
//    static var entityName: String { "ImageFileEntity" }
}

extension JSONFileEntity: Syncable {
//    static var entityName: String { "JSONFileEntity" }
}

extension Meal: EntityRepresentable {
    static var entityType: MealEntity.Type { MealEntity.self }
}

extension Food: EntityRepresentable {
    static var entityType: FoodEntity.Type { FoodEntity.self }
}

extension ImageFile: EntityRepresentable {
    static var entityType: ImageFileEntity.Type { ImageFileEntity.self }
}

extension JSONFile: EntityRepresentable {
    static var entityType: JSONFileEntity.Type { JSONFileEntity.self }
}

extension Array where Element : EntityRepresentable {
    
    func setSyncStatus(to syncStatus: SyncStatus, in context: NSManagedObjectContext) throws {
        let predicate = NSPredicate(format: "id IN %@", self.map({$0.id}))
        guard let objects = try Element.entityType.objects(for: predicate, in: context) as? [any Syncable] else {
            return
        }
        for object in objects {
            object.syncStatus = syncStatus.rawValue
        }
    }

    func setAsNotSynced(in context: NSManagedObjectContext) throws {
        try setSyncStatus(to: .notSynced, in: context)
    }

    func setAsSyncing(in context: NSManagedObjectContext) throws {
        try setSyncStatus(to: .syncing, in: context)
    }

    func setAsSynced(in context: NSManagedObjectContext) throws {
        try setSyncStatus(to: .synced, in: context)
    }
}

extension DataManager {
    
    /// Go through any updates that we had sent and mark their `syncStatus` and `synced`
    func markUpdatesAsSynced(_ updates: SyncForm.Updates) async {
        let bgContext = coreDataManager.newBackgroundContext()
        await bgContext.perform {
            do {
                if let _ = updates.user {
                    try self.coreDataManager.markUserAsSynced(context: bgContext)
                }
                if let days = updates.days {
                    try self.coreDataManager.markDaysAsSynced(dayIds: days.map({$0.id}),
                                                              context: bgContext)
                }
                if let meals = updates.meals {
                    try meals.setAsSynced(in: bgContext)
//                    try meals.setAsSynced(in: bgContext)
//                    try self.coreDataManager.setSyncStatus(
//                        for: MealEntity.self,
//                        with: meals.map({$0.id}),
//                        to: .synced,
//                        in: bgContext
//                    )
//                    try self.coreDataManager.markMealsAsSynced(mealIds: meals.map({$0.id}),
//                                                               context: bgContext)
                }
                
                if let foods = updates.foods {
                    try foods.setAsSynced(in: bgContext)
//                    try self.coreDataManager.markFoodsAsSynced(ids: foods.map({ $0.id }),
//                                                               context: bgContext)
                }
                
                try bgContext.save()
            } catch {
                print("Error marking updates as synced: \(error)")
            }
        }
    }
    
    /// Go through any deletions we had sent and actually delete them now
    func proceedWithDeletions(_ deletions: SyncForm.Deletions) async {
        
    }
    
    func completeSync(for syncForm: SyncForm) async {
        if let updates = syncForm.updates {
            await markUpdatesAsSynced(updates)
        }
        
        if let deletions = syncForm.deletions {
            await proceedWithDeletions(deletions)
        }
    }
    
    func setFiles(_ syncStatus: SyncStatus, to newSyncStatus: SyncStatus) async throws {
        let files = try await getFilesWithSyncStatus(syncStatus)
        let bgContext = coreDataManager.newBackgroundContext()
        await bgContext.perform {
            do {
                try files.imageFiles.setSyncStatus(to: newSyncStatus, in: bgContext)
                try files.jsonFiles.setSyncStatus(to: newSyncStatus, in: bgContext)
                try bgContext.save()
            } catch {
                print("Error setting \(syncStatus) files to \(newSyncStatus): \(error)")
            }
        }
    }

    func process(_ serverSyncForm: SyncForm, sentFor deviceSyncForm: SyncForm) async throws {
        guard let _ = user?.id else {
            throw SyncError.syncPerformedWithoutFetchedUser
        }

        if !serverSyncForm.isEmpty {
            print("💧→ Received \(serverSyncForm.description)")
        }

        if let updates = serverSyncForm.updates {
            try await processUpdates(updates)
        }
        
        processDeletions()
        
        /// Now complete the sync for the device sync form
        await completeSync(for: deviceSyncForm)
        
        versionTimestamp = serverSyncForm.versionTimestamp
    }
    
    
    func processDeletions() {
        //TODO: For each entity in deletions
        // If device.updatedAt < server.deletedAt
        //     delete the entity, make sure we do it in the correct order depending on entity type
        // Else
        //     do not delete as we've had edits to the object since the deletion occured
    }
    
    func processUpdates(_ updates: SyncForm.Updates) async throws {

        let bgContext =  coreDataManager.newBackgroundContext()

        /// Our changes weren't being merged, which we discovered thanks to
        /// [this answer](https://stackoverflow.com/a/63753917)
        let observer = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: bgContext, queue: .main)
        { notification in
            self.coreDataManager.viewContext.mergeChanges(fromContextDidSave: notification)
        }
        
        await bgContext.perform {
            do {
                guard let _ = self.user else { throw SyncError.syncPerformedWithoutFetchedUser }

                if let user = updates.user {
                    try self.updateUser(with: user, in: bgContext)
                }

                if let goalSets = updates.goalSets, !goalSets.isEmpty {
                    try self.createOrUpdateGoalSets(goalSets, in: bgContext)
                }
                
                if let foods = updates.foods, !foods.isEmpty {
                    try self.createOrUpdateFoodsAndBarcodes(foods, in: bgContext)
                }
                
                if let days = updates.days, !days.isEmpty {
                    try self.createOrUpdateDays(days, in: bgContext)
                }
                
                if let meals = updates.meals, !meals.isEmpty {
                    try self.createOrUpdateMeals(meals, in: bgContext)
                }
                
                if let foodItems = updates.foodItems, !foodItems.isEmpty {
                    try self.createOrUpdateFoodItems(foodItems, in: bgContext)
                }
                
                if let fastingActivities = updates.fastingActivities, !fastingActivities.isEmpty {
                    try self.updateFastingActivities(fastingActivities, in: bgContext)
                }
                
            } catch {
                print("Error: \(error)")
            }
        }
        
        NotificationCenter.default.removeObserver(observer)

        //TODO: For each entity in updates
        // If it doesn't exist on device,
        //     insert it
        // If it exists, and server.updatedAt > device.updatedAt
        //     update existing object with received, by entity type (updatedAt flag should be set to server's)
    }
    
    func updateUser(with serverUser: User, in context: NSManagedObjectContext) throws {
        guard let deviceUser = try coreDataManager.userEntity(context: context) else {
            throw CoreDataManagerError.couldNotFindCurrentUser
        }
        try deviceUser.updateWithServerUser(serverUser)
        try context.save()
     
        /// Update the locally stored `User` before sending a notification out—make sure it's on the main thread
        DispatchQueue.main.async {
            do {
                try self.fetchUser()
            } catch {
                print("Error fetching newly updated user: \(error)")
            }
            
            NotificationCenter.default.post(name: .didUpdateUser, object: nil)
        }        
    }
    
    func createOrUpdateDays(_ days: [Day], in context: NSManagedObjectContext) throws {
        try days.forEach { day in
            try createOrUpdateDay(day, in: context)
        }
        
        DispatchQueue.main.async {
            /// Send a notification on the main thread
            NotificationCenter.default.post(
                name: .didUpdateDays,
                object: nil
            )
        }

    }
    
    func createOrUpdateDay(_ serverDay: Day, in context: NSManagedObjectContext) throws {
        
        let goalSetEntity: GoalSetEntity?
        if let goalSet = serverDay.goalSet {
            guard let entity = try coreDataManager.fetchGoalSetEntity(with: goalSet.id, context: context) else {
                throw CoreDataManagerError.missingGoalSetEntity
            }
            goalSetEntity = entity
        } else {
            goalSetEntity = nil
        }
        
        if let day = try coreDataManager.dayEntity(with: serverDay.id, context: context) {
            print("📝 Updating existing Day")
            try day.update(
                with: serverDay,
                goalSetEntity: goalSetEntity,
                in: context
            )
            
        } else {
            
            let dayEntity = DayEntity(
                context: context,
                day: serverDay,
                goalSetEntity: goalSetEntity
            )
            print("✨ Inserting Day")
            context.insert(dayEntity)
        }
        
        try context.save()

        /// If the day exists—we've probably changed the goal, or goal params
        ///     so simply update it by replacing it
        ///     send a notification saying that the `Day` was changed
        /// Otherwise
        ///     add it
        ///     we don't need to post notifications about this right now (Diary View will simply get meals being added)
    }
    
    //MARK: - FoodItems
    func createOrUpdateFoodItems(_ foodItems: [FoodItem], in context: NSManagedObjectContext) throws {
        try foodItems.forEach { foodItem in
            try createOrUpdateFoodItem(foodItem, in: context)
        }

        //TODO: Consider these and revisit the decision to and how we are sending a notification
        /// Do we need this? And if so, do we need to send *all* created food items,
        /// For instance, when a new app instance is launched?
        /// Shouldn't it be just for the sliding window we currently have?
        /// What about `FoodItem`s that describe children food items for recipes and plates?
        DispatchQueue.main.async {
            /// Send a notification on the main thread
            NotificationCenter.default.post(
                name: .didUpdateFoodItems,
                object: nil,
                userInfo: [Notification.Keys.foodItems: foodItems]
            )
        }
    }
    
    func createOrUpdateFoodItem(
        _ serverFoodItem: FoodItem,
        in context: NSManagedObjectContext
    ) throws {
        
        let shouldDelete: Bool
        /// Check that it has a deleted at timestamp **and** belongs to a meal (as we do not hard delete food items that are children of others (since these represent past recipes and plates, which we want to keep around)
        if let deletedAt = serverFoodItem.deletedAt, deletedAt > 0, serverFoodItem.meal != nil {
            shouldDelete = true
        } else {
            shouldDelete = false
        }
        
        guard !shouldDelete else {
            print("🗑 Deleting FoodItem")
            try coreDataManager.hardDeleteFoodItemEntity(with: serverFoodItem.id, context: context)
            return
        }
        
        guard let foodEntity = try coreDataManager.foodEntity(with: serverFoodItem.food.id, context: context) else {
            throw CoreDataManagerError.missingFood
        }
        
        guard let mealId = serverFoodItem.meal?.id,
              let mealEntity = try coreDataManager.mealEntity(with: mealId, context: context) else {
            throw CoreDataManagerError.missingMeal
        }

        if let foodItem = try coreDataManager.foodItemEntity(
            with: serverFoodItem.id,
            context: context
        ) {
            print("📝 Updating existing FoodItem")
            try foodItem.update(
                amount: serverFoodItem.amount,
                markedAsEatenAt: serverFoodItem.markedAsEatenAt,
                foodEntity: foodEntity,
                mealEntity: mealEntity,
                sortPosition: serverFoodItem.sortPosition,
                syncStatus: .synced,
                updatedAt: serverFoodItem.updatedAt,
                deletedAt: serverFoodItem.deletedAt,
                postNotifications: false,
                in: context
            )
            
//            let updatedFoodItem = FoodItem(from: foodItem)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                NotificationCenter.default.post(
//                    name: .didUpdateMealFoodItem,
//                    object: nil,
//                    userInfo: [
//                        Notification.Keys.foodItem: updatedFoodItem
//                    ]
//                )
//            }
            
        } else {
            print("✨ Inserting FoodItem")
            let foodItemEntity = FoodItemEntity(context: context, foodItem: serverFoodItem, foodEntity: foodEntity, mealEntity: mealEntity)
            context.insert(foodItemEntity)
        }

        try context.save()
    }
    
    //MARK: - FastingActivity
    func updateFastingActivities(_ fastingActivities: [FastingActivity], in context: NSManagedObjectContext) throws {
        try fastingActivities.forEach { fastingActivity in
            try updateFastingActivity(fastingActivity, in: context)
        }
    }
    
    func updateFastingActivity(
        _ serverFastingActivity: FastingActivity,
        in context: NSManagedObjectContext
    ) throws {
        
        guard let entity = try coreDataManager.fastingActivityEntity(
            with: serverFastingActivity.id,
            context: context
        ) else {
            return
        }

        if let deletedAt = serverFastingActivity.deletedAt, deletedAt > 0 {
            /// We're only concerned about deleting `FastingActivity` objects created on this device
            try coreDataManager.hardDeleteFastingActivityEntity(with: serverFastingActivity.id, context: context)
            print("🗑 (Hard) Deleted FastingActivity")
        } else {
            entity.update(with: serverFastingActivity, context: context)
            try context.save()
        }

    }
    
    //MARK: - GoalSets
    func createOrUpdateGoalSets(_ goalSets: [GoalSet], in context: NSManagedObjectContext) throws {
        try goalSets.forEach { goalSet in
            try createOrUpdateGoalSet(goalSet, in: context)
        }

        //TODO: Respond to notification so that we may update the UI with it
        /// [ ] Update list of GoalSet (Diets or MealTypes) if we're on it
        /// [ ] Update DaySummary if we're on it
        /// [ ] Update the bottom of Day if we're on it
        DispatchQueue.main.async {
            /// Send a notification on the main thread
            NotificationCenter.default.post(
                name: .didUpdateGoalSets,
                object: nil,
                userInfo: [Notification.Keys.goalSets: goalSets]
            )
        }
    }
    
    func createOrUpdateGoalSet(
        _ serverGoalSet: GoalSet,
        in context: NSManagedObjectContext
    ) throws {
        
        if let existingGoalSetEntity = try coreDataManager.fetchGoalSetEntity(
            with: serverGoalSet.id,
            context: context
        ) {
            print("📝 Updating existing GoalSet")
            try existingGoalSetEntity.update(with: serverGoalSet, in: context)
        } else {
            print("✨ Inserting GoalSet")
            let goalSetEntity = GoalSetEntity(context: context, goalSet: serverGoalSet)
            context.insert(goalSetEntity)
        }

        try context.save()
    }
    
    //MARK: - Meals
    
    func createOrUpdateMeals(_ meals: [Meal], in context: NSManagedObjectContext) throws {
        try meals.forEach { meal in
            try createOrUpdateMeal(meal, in: context)
        }

        /// Send a notification on the main thread
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .didUpdateMeals,
                object: nil,
                userInfo: [Notification.Keys.meals: meals]
            )
        }
    }
    
    func createOrUpdateMeal(_ serverMeal: Meal, in context: NSManagedObjectContext) throws {
        
        let goalSetEntity: GoalSetEntity?
        if let goalSet = serverMeal.goalSet {
            guard let entity = try coreDataManager.fetchGoalSetEntity(with: goalSet.id) else {
                throw CoreDataManagerError.missingGoalSetEntity
            }
            goalSetEntity = entity
        } else {
            goalSetEntity = nil
        }
        
        if let deletedAt = serverMeal.deletedAt, deletedAt > 0 {
            
            print("🗑 Deleting Meal")
            try coreDataManager.hardDeleteMealEntity(with: serverMeal.id, context: context)
            
        } else if let meal = try coreDataManager.mealEntity(with: serverMeal.id, context: context) {
            
            print("📝 Updating existing Meal")
            try meal.update(
                with: serverMeal,
                goalSetEntity: goalSetEntity,
                in: context
            )
            
            let dayMeal = DayMeal(from: meal)
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .didUpdateMeal,
                    object: nil,
                    userInfo: [Notification.Keys.dayMeal: dayMeal]
                )
            }
            
        } else {
            
            guard let dayEntity = try coreDataManager.fetchDayEntity(
                calendarDayString: serverMeal.day.calendarDayString,
                context: context
            ) else {
                throw DataManagerError.noDayFoundWhenInsertingMealFromServer
            }
            
            let mealEntity = MealEntity(
                context: context,
                meal: serverMeal,
                dayEntity: dayEntity,
                goalSetEntity: goalSetEntity
            )
            print("✨ Creating Meal")
            context.insert(mealEntity)
        }
        
        try context.save()
    }

    //MARK: - Foods
    func createOrUpdateFoodsAndBarcodes(_ foods: [Food], in context: NSManagedObjectContext) throws {
        try foods.forEach { food in
            try createOrUpdateFoodAndBarcodes(food, in: context)
        }

        /// Send a notification on the main thread
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .didUpdateFoods,
                object: nil,
                userInfo: [Notification.Keys.foods: foods]
            )
        }
    }
    
    func createOrUpdateFoodAndBarcodes(_ serverFood: Food, in context: NSManagedObjectContext) throws {
        if let _ = try coreDataManager.foodEntity(with: serverFood.id, context: context) {
            print("📝 Updating existing Meal (Not implemented yet!)")
            /// [ ] We should be updating foods for when the metadata such as `lastUsedAt` and `numberOfTimesUsedGlobally` or `publishedStatus` changes
            /// [ ] Detect when our foods go from `pendingVerifiation` to a result and notify the user—if not here, at least when it occurs on the server's end!
//            try food.update(with: serverFood, in: context)
        } else {
            let foodEntity = FoodEntity(context: context, food: serverFood)
            
            for foodBarcode in serverFood.info.barcodes {
                let barcodeEntity = BarcodeEntity(context: context, foodBarcode: foodBarcode, foodEntity: foodEntity)
                print("✨ Inserting Barcode: \(foodBarcode.payload)")
                context.insert(barcodeEntity)
            }
            
            print("✨ Inserting Food")
            context.insert(foodEntity)
        }
        
        try context.save()
    }
}
