import Foundation

extension NetworkManager {
    //TODO: Rewrite this
    public func postRequestForImage(_ imageData: Data, imageId: UUID) -> URLRequest {
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: URL(string: "\(baseUrlString)/foods/image")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()

        let formFields = ["id": imageId.uuidString]

        for (key, value) in formFields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }

        httpBody.append(convertFileData(fieldName: "data",
                                        fileName: "\(imageId.uuidString).jpg",
                                        mimeType: "image/jpg",
                                        fileData: imageData,
                                        using: boundary))

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        return request
    }
}
