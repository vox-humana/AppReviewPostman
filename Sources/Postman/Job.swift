import AppReview
import Foundation
import NIO

struct Job {
    let appId: String
    let countryCode: String
    let mustacheTemplate: String
    let postURL: URL
    let translator: Watson?
}

extension Job {
    struct Watson {
        let url: URL
        let apikey: String
    }
}

extension Job {
    func run(group: EventLoopGroup, lastReviewId: Int) throws -> EventLoopFuture<Int> {
        let client = try HTTPClient(group: group)

        return client
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
                // send only one the latest message if there is no previous history
                if lastReviewId == 0 {
                    return Array(reviews.suffix(1))
                }
                return reviews
            }
            .flatMap { [translator] (reviews: [Review]) -> EventLoopFuture<[Review]> in
                let eventLoop = group.next()
                let messageTranslate = { [eventLoop] (message: String) -> EventLoopFuture<String?> in
                    guard let translator = translator else {
                        return eventLoop.makeSucceededFuture(nil)
                    }
                    return client.translate(message: message, translator: translator, eventLoop: eventLoop)
                }

                let translateReviews = reviews.map { review -> EventLoopFuture<Review> in
                    messageTranslate(review.message).map { translation in
                        guard let translation = translation else { return review }
                        return review.adding(translation: translation)
                    }
                }

                let f0 = eventLoop.makeSucceededFuture([Review]())
                let body = f0.fold(translateReviews) { (acc: [Review], u: Review) -> EventLoopFuture<[Review]> in
                    eventLoop.makeSucceededFuture(acc + [u])
                }
                return body
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
                let sendFutures = messages.map { message, id -> EventLoopFuture<Int> in
                    // TODO: different content type
                    let body = message.data(using: .utf8).map { HTTPRequest.Body(data: $0, type: .json) }
                    return client
                        .send(request: .init(postURL, method: .POST, body: body))
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
