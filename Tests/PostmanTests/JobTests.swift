@testable import Postman
import XCTest
#if canImport(FoundationNetworking)
    import struct FoundationNetworking.URLRequest
#endif

final class JobTests: XCTestCase {
    func testMultipleJobs() throws {
        let appId = "42"
        let codeAU = CountryCode.AU
        let codeNZ = CountryCode.NZ
        let postURL = URL(string: "POST")!
        let transport = MockTransport(
            [
                postURL: "",
                URL.reviewFeedURL(for: appId, countryCode: codeAU): try ReviewsFeed.testFeed(for: "feed"),
                URL.reviewFeedURL(for: appId, countryCode: codeNZ): try ReviewsFeed.testFeed(for: "feed"),
            ]
        )
        // Can't use `async` annotation for test method on Linux
        // https://bugs.swift.org/browse/SR-15230
        let expectation = XCTestExpectation(description: "job")
        Task {
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
            XCTAssertEqual(transport.postRequestsCount, 3)
            XCTAssertEqual(storage, [.AU: 6_184_999_566, .NZ: 6_184_999_566])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60)
    }

    func testJob() throws {
        let appId = "42"
        let code = CountryCode.AU
        let postURL = URL(string: "POST")!
        let template = """
        {"text": "{{stars}}\n{{message}}\n{{contry_flag}} {{author}}"}
        """
        let transport = MockTransport(
            [
                postURL: "",
                URL.reviewFeedURL(for: appId, countryCode: code): try ReviewsFeed.testFeed(for: "feed"),
            ]
        )
        // Can't use `async` annotation for test method on Linux
        // https://bugs.swift.org/browse/SR-15230
        let expectation = XCTestExpectation(description: "job")
        Task {
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
            XCTAssertEqual(storage, [.AU: 6_184_999_566])
            let request = try XCTUnwrap(transport.lastPostRequest)
            XCTAssertEqual(request, """
            {\"text\": \"★★★★★\nGitHub is by far the best, not only because it’s the only one out there to offer a great mobile app (where you can even browse the source code) but also because its UI is sooo gooood!!!!!\n ph7enry\"}
            """)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60)
    }

    func testPostingFailure() throws {
        let appId = "42"
        let code = CountryCode.AU
        let feedURL = URL.reviewFeedURL(for: appId, countryCode: code)
        let transport = MockTransport(
            [
                feedURL: try ReviewsFeed.testFeed(for: "feed"),
            ]
        )
        // Can't use `async` annotation for test method on Linux
        // https://bugs.swift.org/browse/SR-15230
        let expectation = XCTestExpectation(description: "job")
        Task {
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
            XCTAssertTrue(storage.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 60)
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
        let url = try XCTUnwrap(Bundle.module.url(forResource: resource, withExtension: "json"))
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ReviewsFeed.self, from: data)
    }
}
