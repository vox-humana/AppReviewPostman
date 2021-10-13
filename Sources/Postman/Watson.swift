import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

struct WatsonRequestData: Encodable {
    let text: String
    let target: String = "en"
}

struct WatsonResponse: Decodable {
    struct Translation: Decodable {
        let translation: String
    }

    let translations: [Translation]
}

extension Job {
    struct Watson {
        let url: URL
        let apikey: String
    }
}

extension Job.Watson {
    func makeRequest(requestData: WatsonRequestData) throws -> URLRequest {
        let authData = "apikey:\(apikey)".data(using: .utf8)!
        let data = try JSONEncoder().encode(requestData)
        var request = URLRequest(
            url: url.appendingPathComponent("/v3/translate?version=2018-05-01"),
            jsonData: data
        )
        request.setValue("Basic \(authData.base64EncodedString())", forHTTPHeaderField: "Authorization")
        return request
    }
}
