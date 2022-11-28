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

        NotificationCenter.default.addObserver(
            self, selector: #selector(serverDidUpdateFoods),
            name: .didUpdateFoods, object: nil
        )
        
        //TODO: Add notification for GoalSets
    }
}
