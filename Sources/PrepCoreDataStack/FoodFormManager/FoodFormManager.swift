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
    
    public func save(formOutput: FoodFormOutput) async throws {
        /// Create a concurrent task group to:
        /// - Persist each of the images to disk
        /// - Persist the json data to disk
        /// - Create and save the entity for UserFoodEntity
        /// - Create and save the entities for UserFoodImageEntity
        /// - Create and save the entity for UserFoodFormDataEntity
        /// Once all of them are finished
        ///     Then return with the result
        ///     Get the DataManager singleton to refresh

        return try await withTaskGroup(of: Result<FoodSaveStep, FoodSaveError>.self) { group in
            
            let foodId = UUID()
            
            for (uuid, image) in formOutput.images {
                /// Add the task to persist the image to disk
                group.addTask {
                    return await self.persistImage(image, with: uuid)
                }
                
                /// Add the task to save the `UserFoodImageEntity`
                group.addTask {
                    return await self.saveImageFileEntity(for: uuid)
                }
            }

            /// Add the task to persist the json data to disk
            group.addTask {
                return await self.persistJSONData(formOutput.fieldsAndSourcesJSONData, for: foodId)
            }
            
            /// Add the task to save the `UserFoodEntity`
            group.addTask {
                return await self.saveUserFoodEntity(formOutput.createForm, uuid: foodId)
            }

            let start = CFAbsoluteTimeGetCurrent()
            
            for await result in group {
                switch result {
                case .success(let step):
                    print("✨ Step: \(step) completed in \(CFAbsoluteTimeGetCurrent()-start)s")
                case .failure(let error):
                    print("⚠️ Error: \(error)")
                }
            }
            
            print("✅ All steps completed in \(CFAbsoluteTimeGetCurrent()-start)s")
        }
    }
}
