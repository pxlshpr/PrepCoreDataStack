import Foundation
import SwiftUI
import SwiftSugar
import PrepDataTypes

public class NetworkManager {
    
    public enum Endpoint {
        case sync
        case backup
        case fastingActivity
        case presetFoodsSearch
        
        var path: String {
            switch self {
            case .sync:
                return "sync"
            case .backup:
                return "backup"
            case .fastingActivity:
                return "fastingActivity"
            case .presetFoodsSearch:
                return "presetFoods/searchFull"
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
    
    func post(_ encodable: Encodable, to endpoint: Endpoint) async throws -> Data {
        guard let request = postRequestForEncodable(encodable, to: endpoint) else {
            throw NetworkManagerError.failedToCreatePostRequest
        }
        
        return try await post(request: request)
    }
    
    func post(request: URLRequest) async throws -> Data {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
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
