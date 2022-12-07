import Foundation
import CoreData
import PrepDataTypes

public class DataManager: ObservableObject {
    
    public static let shared = DataManager()
    let coreDataManager: CoreDataManager
    @Published internal(set) public var user: User? = nil

    public var daysToSync: Range<Date>? = nil

    @Published public var goalSets: [GoalSet] = []

    //TODO: We need to mitigate situations where this might be extremely large
    @Published var myFoods: [Food] = []

    @Published public var fastingTimerState: FastingTimerState? = nil
    
    convenience init() {
        self.init(coreDataManager: CoreDataManager())
        coreDataManager.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
        do {
            try fetchUser()
        } catch {
            print("CoreData error while fetching user: \(error)")
        }
        
        loadMyFoods()
        loadGoalSets()
        loadFastingTimerState()

        NotificationCenter.default.addObserver(
            self, selector: #selector(didUpdateFoods),
            name: .didUpdateFoods, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(didUpdateGoalSets),
            name: .didUpdateGoalSets, object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(didAddMeal),
            name: .didAddMeal, object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(didDeleteMeal),
            name: .didDeleteMeal, object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(didUpdateMeals),
            name: .didUpdateMeals, object: nil
        )

        NotificationCenter.default.addObserver(
            self, selector: #selector(didUpdateMeal),
            name: .didUpdateMeal, object: nil
        )
    }
}

import SwiftUI

extension DataManager {
    func updateFastingTimer() {
        withAnimation {
            loadFastingTimerState()
        }
    }
}
