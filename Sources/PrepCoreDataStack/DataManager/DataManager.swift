import Foundation
import CoreData
import PrepDataTypes

public class DataManager: ObservableObject {
    
    public static let shared = DataManager()
    let coreDataManager: CoreDataManager
    @Published internal(set) public var user: User? = nil

    public var daysToSync: Range<Date>? = nil

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

        NotificationCenter.default.addObserver(
            self, selector: #selector(serverDidUpdateFoods),
            name: .didUpdateFoods, object: nil
        )
    }
    
    @objc func serverDidUpdateFoods(notification: Notification) {
        DispatchQueue.main.async {
            self.loadMyFoods()
        }
    }
    
    func loadMyFoods() {
        Task {
            let foods = try await getMyFoods()
            await MainActor.run {
                self.myFoods = foods
            }
        }
    }
}
