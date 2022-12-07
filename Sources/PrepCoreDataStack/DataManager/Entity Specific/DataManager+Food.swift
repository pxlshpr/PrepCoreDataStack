import Foundation
import PrepDataTypes

public extension DataManager {
    func addNewImageFile(_ imageFile: ImageFile) throws {
        let imageFileEntity = ImageFileEntity(context: coreDataManager.viewContext, imageFile: imageFile)
        try coreDataManager.saveImageFileEntity(imageFileEntity)
    }
    
    func addNewJSONFile(_ jsonFile: JSONFile) throws {
        let jsonFileEntity = JSONFileEntity(context: coreDataManager.viewContext, jsonFile: jsonFile)
        try coreDataManager.saveJSONFileEntity(jsonFileEntity)
    }
    
    func addNewFood(fromForm form: UserFoodCreateForm) throws {
        /// Construct the new `FoodEntity` and insert it
        let foodEntity = FoodEntity(context: coreDataManager.viewContext, form: form)
        coreDataManager.insertFoodEntity(foodEntity)
        
        /// Created `BarcodeEntities` for each barcode and insert them
        for barcode in form.info.barcodes {
            let barcodeEntity = BarcodeEntity(
                context: coreDataManager.viewContext,
                foodBarcode: barcode,
                foodEntity: foodEntity
            )
            coreDataManager.insertBarcodeEntity(barcodeEntity)
        }
        
        try coreDataManager.save()
        
        /// Send a notification named`didAddFood` with the new `Food`
        let food = Food(from: foodEntity)
        writeEncodableToJSON(food, type: "food")
        NotificationCenter.default.post(
            name: .didAddFood,
            object: nil,
            userInfo: [
                Notification.Keys.food: food
            ]
        )
        
        /// Insert the new food at the start of the `myFoods` array
        self.myFoods.insert(food, at: 0)
    }
}

public extension DataManager {
    func loadMyFoods() {
        Task {
            let foods = try await getMyFoods()
            await MainActor.run {
                self.myFoods = foods
            }
        }
    }
    
    func loadFastingTimerState() {
        guard let lastMealTime else {
            fastingTimerState = nil
            return
        }
        fastingTimerState = FastingTimerState(
            lastMealTime: lastMealTime,
            nextMealTime: nextMealTime
        )
    }
    
    var lastMealTime: Date? {
        do {
            guard let meal = try coreDataManager.latestMealBeforeNow() else {
                return nil
            }
            print("Last Meal: \(meal.name!) at \(meal.time)")
            return Date(timeIntervalSince1970: meal.time)
        } catch {
            print("Error getting last meal: \(error)")
            return nil
        }
    }
    
    var nextMealTime: Date? {
        do {
            guard let meal = try coreDataManager.earliestMealAfterNow() else {
                return nil
            }
            print("Next Meal: \(meal.name!) at \(meal.time)")
            return Date(timeIntervalSince1970: meal.time)
        } catch {
            print("Error getting next meal: \(error)")
            return nil
        }
    }
    
    @objc func didUpdateFoods(notification: Notification) {
        DispatchQueue.main.async {
            self.loadMyFoods()
        }
    }

    @objc func didUpdateGoalSets(notification: Notification) {
        DispatchQueue.main.async {
            self.loadGoalSets()
        }
    }

    func getMyFoods() async throws -> [Food] {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try coreDataManager.myFoodEntities() { foodEntities in
                    let foods = foodEntities.map { Food(from: $0) }
                    continuation.resume(returning: foods)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}


public func writeEncodableToJSON(_ encodable: Encodable, type: String) {
    guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    Task {
        do {
            let directoryUrl = documentsUrl.appending(component: UUID().uuidString)
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: false)
            
            let encoder = JSONEncoder()
            let data = try encoder.encode(encodable)

            let url = directoryUrl.appending(component: "\(UUID().uuidString).json")
            try data.write(to: url)
            print("📝 Wrote \(type) to: \(directoryUrl)")
        } catch {
            print("Error writing: \(error)")
        }
    }
}
