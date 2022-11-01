import Foundation
import SwiftUI
import SwiftSugar
import PrepDataTypes

public class NetworkManager {
    
    public enum Endpoint {
        case sync
        var path: String {
            switch self {
            case .sync:
                return "sync"
            }
        }
    }
    
    let isLocal: Bool
    
    init(isLocal: Bool) {
        self.isLocal = isLocal
    }
    
    var baseUrlString: String {
        isLocal ? "http://127.0.0.1:8083" : "https://pxlshpr.app/prep"
    }
    
    public static var local = NetworkManager(isLocal: true)
    public static var server = NetworkManager(isLocal: false)
    
    func post(_ encodable: Encodable, to endpoint: Endpoint) async throws -> Data? {
        guard let post = postRequestForEncodable(encodable, to: endpoint) else {
            throw NetworkManagerError.failedToCreatePostRequest
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: post)
            guard response.httpResponse?.isSuccessful == true else {
                throw NetworkManagerError.httpError(response.httpResponse?.statusCode)
            }
            return data
        } catch {
            throw NetworkManagerError.couldNotConnectToServer
        }
    }
}

enum NetworkManagerError: Error {
    case failedToCreatePostRequest
    case couldNotConnectToServer
    case httpError(Int?)
}

extension URLResponse {
    var httpResponse: HTTPURLResponse? {
        return self as? HTTPURLResponse
    }
}
extension HTTPURLResponse {
    var isSuccessful: Bool {
        return 200 ... 299 ~= statusCode
    }
}
