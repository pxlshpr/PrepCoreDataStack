import Foundation
import PrepDataTypes
import UIKit

enum FoodSaveStep {
    case persistImage(UUID)
    case saveUserFoodImageEntity(UUID)
    case persistJSON
    case saveUserFoodJSONEntity
    case saveUserFoodEntity
}

public class FoodFormManager {
    
    public static let shared = FoodFormManager()
    
    public func save(formOutput: FoodFormOutput) throws {
//        let userFood = UserFood(from: formOutput.createForm)
//        try DataManager.shared.save(userFood: userFood)
//        DataManager.shared.refresh()
//
//        let entity = UserFoodEntity(context: backgroundContext, userFood: userFood)
//        try await DataManager.shared.save(userFood: formOutput.createForm)
//        return try await withThrowingTaskGroup(of: Result<FoodSaveStep, FoodSaveError>.self) { group in
//            
//            let foodId = UUID()
//            
//            for (uuid, image) in formOutput.images {
//                /// Add the task to persist the image to disk
//                group.addTask {
//                    return await self.persistImage(image, with: uuid)
//                }
//                
//                /// Add the task to save the `UserFoodImageEntity`
//                group.addTask {
//                    return await self.saveImageFileEntity(for: uuid)
//                }
//            }
//
//            /// Add the task to persist the json data to disk
//            group.addTask {
//                return await self.persistJSONData(formOutput.fieldsAndSourcesJSONData, for: foodId)
//            }
//            
//            /// Add the task to save the `UserFoodEntity`
//            group.addTask {
//                return await self.saveUserFoodEntity(formOutput.createForm, uuid: foodId)
//            }
//
//            let start = CFAbsoluteTimeGetCurrent()
//            
//            for try await result in group {
//                switch result {
//                case .success(let step):
//                    print("💾 Save Step: \(step) completed in \(CFAbsoluteTimeGetCurrent()-start)s")
//                case .failure(let error):
//                    throw error
//                }
//            }
//            
//            print("✅ Save completed in \(CFAbsoluteTimeGetCurrent()-start)s … forcing an upload")
//            
//            SyncManager.shared.uploadNotSyncedData()
//        }
    }
}
