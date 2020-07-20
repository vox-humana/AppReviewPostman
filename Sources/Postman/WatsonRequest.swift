import AppReview
import Foundation

struct WatsonRequestData: Encodable {
    let text: String
    let target: String = "en"
}

extension HTTPRequest {
    init?(url: URL, apiKey: String, requestData: WatsonRequestData) {
        guard let authData = "apikey:\(apiKey)".data(using: .utf8) else {
            return nil
        }
        guard let data = try? JSONEncoder().encode(requestData) else {
            return nil
        }
        self.init(
            url.appendingPathComponent("/v3/translate?version=2018-05-01"),
            method: .POST,
            body: .init(data: data, type: .json),
            headers: ["Authorization": "Basic \(authData.base64EncodedString())"]
        )
    }
}
