import Foundation
import PrepDataTypes
import UIKit

enum FoodSaveStep {
    case persistImage(UUID)
    case persistJSON
}

public class FoodFormManager {
    
    public static let shared = FoodFormManager()
    
    public func save(_ formOutput: FoodFormOutput) throws {
        
        /// Pass the food details to `DataManager` to be persisted in the backend (and synced to the server eventually)
        try DataManager.shared.addNewFood(fromForm: formOutput.createForm)

        for (uuid, _) in formOutput.images {
            try saveImageFileEntity(for: uuid)
        }
        
        try saveJSONFileEntity(for: formOutput.createForm.id)

        /// Now save the files in the background
        Task {
            return try await withThrowingTaskGroup(of: Result<FoodSaveStep, FoodSaveError>.self) { group in
                let foodId = formOutput.createForm.id
                
                for (uuid, image) in formOutput.images {
                    /// Add the task to persist the image to disk
                    group.addTask {
                        return await self.persistImage(image, with: uuid)
                    }
                }

                /// Add the task to persist the json data to disk
                group.addTask {
                    return await self.persistJSONData(formOutput.fieldsAndSourcesJSONData, for: foodId)
                }

                let start = CFAbsoluteTimeGetCurrent()

                for try await result in group {
                    switch result {
                    case .success(let step):
                        print("💾 Save Step: \(step) completed in \(CFAbsoluteTimeGetCurrent()-start)s")
                    case .failure(let error):
                        throw error
                    }
                }

                print("✅ Save completed in \(CFAbsoluteTimeGetCurrent()-start)s")
            }
        }
    }
}
