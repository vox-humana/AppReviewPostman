import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLSession: NetworkTransport {
    enum ResponseError: Error {
        case invalidHTTPResponse
        case invalidHTTPStatusCode(Int)
    }

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

    func send(request: URLRequest) async throws {
        let (_, response) = try await data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ResponseError.invalidHTTPResponse
        }
        guard httpResponse.statusCode == 200 else {
            throw ResponseError.invalidHTTPStatusCode(httpResponse.statusCode)
        }
    }
}
