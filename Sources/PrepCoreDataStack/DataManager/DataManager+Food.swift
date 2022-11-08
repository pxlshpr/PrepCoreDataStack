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
