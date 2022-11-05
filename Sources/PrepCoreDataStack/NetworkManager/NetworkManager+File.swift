import Foundation

public enum FileType {
    case image, json
    
    var endpoint: String {
        switch self {
        case .image:
            return "image"
        case .json:
            return "json"
        }
    }
    
    var mimeType: String {
        switch self {
        case .image:
            return "image/jpg"
        case .json:
            return "application/json"
        }
    }
}

public extension NetworkManager {
    func postFile(type: FileType, data: Data, id: UUID) async throws -> Data {
        let request = postRequestForFile(type: type, data: data, id: id)
        return try await post(request: request)
    }
}

extension NetworkManager {
    func postRequestForFile(type: FileType, data: Data, id: UUID) -> URLRequest {
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: URL(string: "\(baseUrlString)/sync/\(type.endpoint)")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = NSMutableData()

        let formFields = ["id": id.uuidString]

        for (key, value) in formFields {
            httpBody.appendString(convertFormField(named: key, value: value, using: boundary))
        }

        httpBody.append(convertFileData(fieldName: "data",
                                        fileName: "\(id.uuidString).jpg",
                                        mimeType: type.mimeType,
                                        fileData: data,
                                        using: boundary))

        httpBody.appendString("--\(boundary)--")

        request.httpBody = httpBody as Data
        return request
    }
}
