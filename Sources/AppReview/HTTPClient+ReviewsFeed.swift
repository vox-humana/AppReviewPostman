import Foundation
import NIO

extension HTTPClient {
    public func reviews(for appId: String, countryCode: String) -> EventLoopFuture<[Review]> {
        send(
            request: .init(
                .reviewFeedURL(for: appId, countryCode: countryCode),
                method: .GET,
                body: nil
            )
        )
        .flatMapThrowing {
            try JSONDecoder().decode(ReviewsFeed.self, from: $0)
        }
        .map(\.feed.entry)
        .map { $0.compactMap(Review.init) }
    }
}

extension URL {
    static func reviewFeedURL(for appId: String, countryCode: String) -> URL {
        URL(string: "https://itunes.apple.com/\(countryCode)/rss/customerreviews/id=\(appId)/sortBy=mostRecent/json")!
    }
}
