import Foundation
#if canImport(FoundationNetworking)
    import struct FoundationNetworking.URLRequest
#endif
import Logging

struct Job {
    private let appId: String
    let countryCode: CountryCode
    private let mustacheTemplate: String
    private let postURL: URL
    private let translator: Watson?
    private let transport: NetworkTransport
    private let jobLogger: Logger

    init(
        appId: String,
        countryCode: CountryCode,
        mustacheTemplate: String,
        postURL: URL,
        translator: Watson?,
        transport: NetworkTransport
    ) {
        self.appId = appId
        self.countryCode = countryCode
        self.mustacheTemplate = mustacheTemplate
        self.postURL = postURL
        self.translator = translator
        self.transport = transport
        jobLogger = logger.appending(metadata: "\(appId):\(countryCode)", with: "job")
    }
}

extension Job {
    func run(lastReviewId: Int?) async throws -> Int? {
        defer {
            jobLogger.info("Done")
        }
        jobLogger.info("Starting job with last review id: \(lastReviewId ?? 0)")

        let reviews: [Review] = try await requestReviews(lastReviewId: lastReviewId)
        let translatedReviews = try await translate(reviews: reviews)
        return await posting(reviews: translatedReviews)
    }

    private func requestReviews(lastReviewId: Int?) async throws -> [Review] {
        let reviews: [Review] = try await transport.reviews(for: appId, countryCode: countryCode)
        // send only one the latest message if there is no previous history
        guard let lastReviewId = lastReviewId else {
            jobLogger.info("No previous review id was provided, sending the last one")
            return Array(reviews.prefix(1))
        }
        return reviews
            .filter {
                $0.id > lastReviewId
            }
            .sorted {
                $0.id < $1.id
            }
    }

    private func translate(reviews: [Review]) async throws -> [Review] {
        guard let translator = translator else {
            jobLogger.info("No translator, skipping translation")
            return reviews
        }
        jobLogger.info("Translating \(reviews.count) review(s)...")
        var translatedReviews: [Review] = []
        for review in reviews {
            do {
                let request = try translator.makeRequest(requestData: .init(text: review.message))
                let response: WatsonResponse = try await transport.value(for: request)
                if let translation = response.translations.first?.translation {
                    jobLogger.info("Got translation for \(review.id) review")
                    translatedReviews.append(review.adding(translation: translation))
                } else {
                    jobLogger.info("No translation for \(review.id) review")
                    translatedReviews.append(review)
                }
            } catch {
                jobLogger.error("Failed to translate \(review.id) with \(error)")
            }
        }
        return translatedReviews
    }

    private func posting(reviews: [Review]) async -> Int? {
        var lastPostedReview: Int?
        jobLogger.info("Posting \(reviews.count) review(s)...")
        for review in reviews {
            let message = review.format(
                template: mustacheTemplate,
                countryCode: countryCode,
                jsonEscaping: true
            )
            let request = URLRequest(url: postURL, jsonData: message.data(using: .utf8)!)
            do {
                try await transport.send(request: request)
                jobLogger.info("Posted \(review.id) review")
                lastPostedReview = review.id
            } catch {
                jobLogger.error("Failed to post \(review.id) review with \(error)")
                return lastPostedReview
            }
        }
        return lastPostedReview
    }
}
