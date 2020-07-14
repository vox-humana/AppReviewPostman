import Foundation
import NIOHTTP1

public struct HTTPRequest {
    public struct Body {
        public enum ContentType {
            case json
            case utf8Text
        }

        let data: Data
        let type: ContentType

        public init(data: Data, type: ContentType) {
            self.data = data
            self.type = type
        }
    }

    let url: URL
    let method: HTTPMethod
    let body: Body?

    public init(_ url: URL, method: HTTPMethod, body: Body?) {
        self.url = url
        self.method = method
        self.body = body
    }
}

extension HTTPRequest {
    var host: String {
        url.host ?? "localhost"
    }

    var uri: String {
        var string = url.path.isEmpty ? "/" : url.path
        if let query = url.query {
            string += "?\(query)"
        }
        return string
    }

    var port: Int {
        url.port ?? (url.scheme?.lowercased() == "https" ? 443 : 80)
    }
}

extension HTTPRequest.Body.ContentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .json:
            return "application/json"
        case .utf8Text:
            return "text/plain; charset=utf-8"
        }
    }
}
