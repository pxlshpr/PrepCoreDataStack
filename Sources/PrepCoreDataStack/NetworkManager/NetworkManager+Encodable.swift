import Foundation

extension NetworkManager {
    public func postRequestForEncodable(_ encodable: Encodable, to endpoint: Endpoint) -> URLRequest? {
        guard let url = URL(string: "\(baseUrlString)/\(endpoint.path)") else { return nil }

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(encodable)

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")

            return request
        } catch {
            print("Error encoding: \(error)")
            return nil
        }
    }
}
