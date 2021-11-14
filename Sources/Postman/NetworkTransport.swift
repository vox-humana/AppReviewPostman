import Foundation
#if canImport(FoundationNetworking)
    import struct FoundationNetworking.URLRequest
#endif

protocol NetworkTransport {
    func send(request: URLRequest) async throws
    func value<V>(for request: URLRequest) async throws -> V where V: Decodable
}

extension NetworkTransport {
    func value<V>(from url: URL) async throws -> V where V: Decodable {
        try await value(for: URLRequest(url: url))
    }
}

extension URLRequest {
    init(url: URL, jsonData: Data) {
        self.init(url: url)
        httpMethod = "POST"
        httpBody = jsonData
        setValue("application/json", forHTTPHeaderField: "Content-Type")
        setValue("\(jsonData.count)", forHTTPHeaderField: "Content-Length")
    }
}
