import AppReview
import Foundation
import NIO

struct Job {
    let appId: String
    let countryCode: String
    let mustacheTemplate: String
    let postURL: URL
}

extension Job {
    func run(group: EventLoopGroup, lastReviewId: Int) throws -> EventLoopFuture<Int> {
        let client = try HTTPClient(group: group)

        return try HTTPClient(group: group)
            .reviews(for: appId, countryCode: countryCode)
            .map { reviews in
                reviews
                    .filter {
                        $0.id > lastReviewId
                    }
                    .sorted {
                        $0.id < $1.id
                    }
            }
            .map { reviews in
                // sent only one the latest message if there is no previous history
                if lastReviewId == 0 {
                    return Array(reviews.suffix(1))
                }
                return reviews
            }
            .map { [countryCode, mustacheTemplate] (reviews: [Review]) -> [(String, Int)] in
                Array(
                    zip(
                        reviews.format(template: mustacheTemplate, countryCode: countryCode)
                            .map { $0.replacingOccurrences(of: "\n", with: "\\n") },
                        reviews.map(\.id)
                    )
                )
            }
            .flatMap { [postURL] messages in
                let sendFutures = messages.map { message, id in
                    // TODO: detect application level errors (parse JSON? response)
                    client
                        .send(request: .init(postURL, method: .POST, body: message.data(using: .utf8)))
                        .map { _ in id }
                }
                // execute one by one to return latest successful sent
                let eventLoop = group.next()
                let f0 = eventLoop.makeSucceededFuture(lastReviewId)
                let body = f0.fold(sendFutures) { (_: Int, u: Int) -> EventLoopFuture<Int> in
                    eventLoop.makeSucceededFuture(u)
                }
                return body
            }
    }
}
