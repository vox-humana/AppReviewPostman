import Foundation
@testable import Postman
import Testing
#if canImport(FoundationNetworking)
    import struct FoundationNetworking.URLRequest
#endif

struct JobTests {
    @Test func multipleJobs() async throws {
        let appId = "42"
        let codeAU = CountryCode.AU
        let codeNZ = CountryCode.NZ
        let postURL = URL(string: "POST")!
        let transport = try MockTransport(
            [
                postURL: "",
                URL.reviewFeedURL(for: appId, countryCode: codeAU): ReviewsFeed.testFeed(for: "feed"),
                URL.reviewFeedURL(for: appId, countryCode: codeNZ): ReviewsFeed.testFeed(for: "feed"),
            ]
        )
        var storage: SentStorage = [.AU: 6_062_329_274]
        await Job.runJobs(
            appId: appId,
            countryCodes: [codeAU, codeNZ],
            mustacheTemplate: "{{stars}}",
            postURL: postURL,
            translator: nil,
            transport: transport,
            storage: &storage
        )
        #expect(transport.postRequestsCount == 3)
        #expect(storage == [.AU: 6_184_999_566, .NZ: 6_184_999_566])
    }

    @Test func job() async throws {
        let appId = "42"
        let code = CountryCode.AU
        let postURL = URL(string: "POST")!
        let template = """
        {"text": "{{stars}}\n{{message}}\n{{contry_flag}} {{author}}"}
        """
        let transport = try MockTransport(
            [
                postURL: "",
                URL.reviewFeedURL(for: appId, countryCode: code): ReviewsFeed.testFeed(for: "feed"),
            ]
        )
        var storage = SentStorage()
        await Job.runJobs(
            appId: appId,
            countryCodes: [code],
            mustacheTemplate: template,
            postURL: postURL,
            translator: nil,
            transport: transport,
            storage: &storage
        )
        #expect(storage == [.AU: 6_184_999_566])
        let request = try #require(transport.lastPostRequest)
        #expect(request == """
        {\"text\": \"★★★★★\nGitHub is by far the best, not only because it’s the only one out there to offer a great mobile app (where you can even browse the source code) but also because its UI is sooo gooood!!!!!\n ph7enry\"}
        """)
    }

    @Test func postingFailure() async throws {
        let appId = "42"
        let code = CountryCode.AU
        let feedURL = URL.reviewFeedURL(for: appId, countryCode: code)
        let transport = try MockTransport(
            [
                feedURL: ReviewsFeed.testFeed(for: "feed"),
            ]
        )
        var storage = SentStorage()
        await Job.runJobs(
            appId: appId,
            countryCodes: [code],
            mustacheTemplate: "",
            postURL: URL(string: "POST")!,
            translator: nil,
            transport: transport,
            storage: &storage
        )
        #expect(storage.isEmpty)
    }
}

private final class MockTransport: NetworkTransport {
    enum MockError: Error {
        case notImplemented
    }

    private let responses: [URL: Any]
    var lastPostRequest: String?
    var postRequestsCount: Int = 0

    init(_ responses: [URL: Any]) {
        self.responses = responses
    }

    func send(request: URLRequest) async throws {
        guard let url = request.url, responses[url] != nil else {
            throw MockError.notImplemented
        }
        guard let data = request.httpBody else {
            return
        }
        lastPostRequest = String(data: data, encoding: .utf8)
        postRequestsCount += 1
    }

    func value<V>(for request: URLRequest) async throws -> V where V: Decodable {
        guard let url = request.url, let value = responses[url] else {
            throw MockError.notImplemented
        }
        return value as! V
    }
}

extension ReviewsFeed {
    static func testFeed(for resource: String) throws -> Self {
        let url = try #require(Bundle.module.url(forResource: resource, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ReviewsFeed.self, from: data)
    }
}
