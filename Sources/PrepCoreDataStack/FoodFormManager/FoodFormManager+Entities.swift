import Foundation
import PrepDataTypes

extension FoodFormManager {
    func saveUserFoodEntity(_ createForm: UserFoodCreateForm, uuid: UUID) async -> Result<FoodSaveStep, FoodSaveError> {
        let userFood = UserFood(from: createForm)
        do {
            try DataManager.shared.save(userFood: userFood)
            try DataManager.shared.refresh()
            return .success(.saveUserFoodEntity)
        } catch {
            return .failure(.saveUserFoodEntityError(error))
        }
    }
    
    func saveImageFileEntity(for uuid: UUID) async -> Result<FoodSaveStep, FoodSaveError> {
        let imageFile = ImageFile(id: uuid, syncStatus: .notSynced)
        do {
            try DataManager.shared.save(imageFile: imageFile)
            try DataManager.shared.refresh()
            return .success(.saveUserFoodImageEntity(uuid))
        } catch {
            return .failure(.saveImageFileEntityError(error))
        }
    }
}
