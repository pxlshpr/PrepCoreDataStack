import CoreData
import PrepDataTypes
import SwiftSugar

extension CoreDataManager {
    
    func fetchFoodsInBackground(for searchText: String, completion: @escaping (([FoodEntity]?) -> ())) {
        Task {
            let bgContext =  newBackgroundContext()
            await bgContext.perform {
                do {
                    guard let foods = try self.fetchFoods(for: searchText, context: bgContext) else {
                        completion(nil)
                        return
                    }
                    completion(foods)
                } catch {
                    print("Error: \(error)")
                    completion(nil)
                }
            }
        }
    }
    
    
    func fetchFoods(for searchText: String, context: NSManagedObjectContext) throws -> [FoodEntity]? {
        
        //TODO: First check if its a barcode, and if so—search using it, otherwise do a text search
        if searchText.isBarcode {
            
            let request: NSFetchRequest<BarcodeEntity> = BarcodeEntity.fetchRequest()
            request.predicate = barcodePredicate(for: searchText)
            return try context.fetch(request).compactMap { $0.food }
            
        } else {
            
            let request: NSFetchRequest<FoodEntity> = FoodEntity.fetchRequest()
            request.predicate = foodPredicate(for: searchText, type: .food)
            request.sortDescriptors = foodSearchSortDescriptors
            return try context.fetch(request)
        }
    }
}

extension String {
    var isBarcode: Bool {
        matchesRegex("^[0-9]+$")
    }
}

/// `NSFetchRequest` Helpers
extension CoreDataManager {

    func barcodePredicate(for barcodeString: String, deleted: Bool = false) -> NSPredicate? {
        guard !barcodeString.isEmpty else { return nil }
        let sanitized = barcodeString.trimmingWhitespaces
        let regex = NSString(format: "(^|.* )%@[^ ]*($| .*)", sanitized)
        let format = "payload MATCHES[cd] %@"
        return NSPredicate(format: format, regex)
    }

    func foodPredicate(for searchString: String, type: FoodType, deleted: Bool = false) -> NSPredicate? {
        
        let deletedFormat = "(deletedAt \(deleted ? "!=" : "==") 0)"
        let typeFormat = "(type == %d)"

        guard !searchString.isEmpty else {
            return NSPredicate(format: "\(deletedFormat) AND \(typeFormat)", type.rawValue)
        }
        let sanitized = searchString
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        let regex = NSString(format: "(^|.* )%@[^ ]*($| .*)", sanitized)
        
        let format = "((name MATCHES[cd] %@) OR (brand MATCHES[cd] %@) OR (detail MATCHES[cd] %@)) AND \(deletedFormat) AND \(typeFormat)"
        return NSPredicate(format: format, regex, regex, regex, type.rawValue)
    }
    
    var foodSearchSortDescriptors: [NSSortDescriptor] {
        return [
            NSSortDescriptor(keyPath: \FoodEntity.numberOfTimesConsumed, ascending: false),
            NSSortDescriptor(keyPath: \FoodEntity.lastUsedAt, ascending: false)
        ]
    }
}
