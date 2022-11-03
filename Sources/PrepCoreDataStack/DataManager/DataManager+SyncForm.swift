import Foundation
import PrepDataTypes

extension DataManager {

    func constructSyncForm() async throws -> SyncForm {
        guard let userId = user?.id else {
            throw SyncError.syncPerformedWithoutFetchedUser
        }
        
        let updates = try await constructSyncUpdates()
        let deletions = syncDeletions
        let form = SyncForm(
            updates: updates,
            deletions: deletions,
            userId: userId,
            versionTimestamp: versionTimestamp
        )
        return form
    }

    var syncDeletions: SyncForm.Deletions {
        //TODO: Include all entities (except `UserEntity`) with a deletedAt greater than versionTimestamp
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

                let updated = SyncForm.Updates(
                    user: user,
                    days: days,
                    meals: meals
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
                    try self.coreDataManager.markMealsAsSynced(mealIds: meals.map({$0.id}),
                                                               context: bgContext)
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
    
    func process(_ serverSyncForm: SyncForm, sentFor deviceSyncForm: SyncForm) async throws {
        guard let _ = user?.id else {
            throw SyncError.syncPerformedWithoutFetchedUser
        }
        
        print("💧→ Received \(serverSyncForm.description)")

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
        await bgContext.perform {

            do {
                guard let _ = self.user else { throw SyncError.syncPerformedWithoutFetchedUser }

                if let user = updates.user {
                    try self.updateUser(with: user, in: bgContext)
                }
                if let days = updates.days {
                    try self.createOrUpdateDays(days, in: bgContext)
                }
                if let meals = updates.meals {
                    try self.createOrUpdateMeals(meals, in: bgContext)
                }
                
            } catch {
                print("Error: \(error)")
            }
        }
            
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
        try deviceUser.update(with: serverUser, in: context)
        try context.save()
        
        /// Now fire a notification to inform any interested parties (including ourself)
        NotificationCenter.default.post(name: .didUpdateUser, object: nil)
    }
    
    func createOrUpdateDays(_ days: [Day], in context: NSManagedObjectContext) throws {
        try days.forEach { day in
            try createOrUpdateDay(day, in: context)
        }
    }
    
    func createOrUpdateDay(_ serverDay: Day, in context: NSManagedObjectContext) throws {
        if let day = try coreDataManager.dayEntity(with: serverDay.id, context: context) {
            print("📝 Updating existing Day")
            try day.update(with: serverDay, in: context)
        } else {
            let dayEntity = DayEntity(context: context, day: serverDay)
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
        /// If the meal exists—we've probably changed the completion state, or name, time, etc.
        ///     so simply update it by replacing it
        ///     send a notification saying that the `Meal` was changed
        /// Otherwise
        ///     add it
        ///     send the notification saying that the `Meal` was added
    }
    
    func createOrUpdateMeal(_ serverMeal: Meal, in context: NSManagedObjectContext) throws {
        if let meal = try coreDataManager.mealEntity(with: serverMeal.id, context: context) {
            print("📝 Updating existing Meal")
            try meal.update(with: serverMeal, in: context)
        } else {
            guard let dayEntity = try coreDataManager.fetchDayEntity(calendarDayString: serverMeal.day.calendarDayString, context: context) else {
                throw DataManagerError.noDayFoundWhenInsertingMealFromServer
            }
            let mealEntity = MealEntity(context: context, meal: serverMeal, dayEntity: dayEntity)
            print("✨ Inserting Meal")
            context.insert(mealEntity)
        }
        
        try context.save()

        /// If the day exists—we've probably changed the goal, or goal params
        ///     so simply update it by replacing it
        ///     send a notification saying that the `Day` was changed
        /// Otherwise
        ///     add it
        ///     we don't need to post notifications about this right now (Diary View will simply get meals being added)
    }

}
