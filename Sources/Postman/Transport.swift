import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

enum ResponseError: Error {
    case invalidHTTPResponse
    case invalidHTTPStatusCode(Int)
}

extension URLSession {
    func value<V>(for request: URLRequest) async throws -> V where V: Decodable {
        let (data, response) = try await self.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw ResponseError.invalidHTTPStatusCode(httpResponse.statusCode)
        }
        return try JSONDecoder().decode(V.self, from: data)
    }

    func value(for request: URLRequest) async throws {
        let (data, response) = try await self.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw ResponseError.invalidHTTPStatusCode(httpResponse.statusCode)
        }
    }

    func value<V>(from url: URL) async throws -> V where V: Decodable {
        let (data, response) = try await self.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw ResponseError.invalidHTTPStatusCode(httpResponse.statusCode)
        }
        return try JSONDecoder().decode(V.self, from: data)
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
