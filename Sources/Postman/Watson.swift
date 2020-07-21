import AppReview
import Foundation
import NIO

extension HTTPClient {
    func translate(
        message: String, translator: Job.Watson, eventLoop: EventLoop
    ) -> EventLoopFuture<String?> {
        guard
            let request = HTTPRequest(
                url: translator.url,
                apiKey: translator.apikey,
                requestData: .init(text: message)
            )
        else {
            logger.error("Translation request is empty, ignoring translation")
            return eventLoop.makeSucceededFuture(nil)
        }

        return send(request: request)
            .map { data in
                try? JSONDecoder().decode(WatsonResponse.self, from: data).translations.first?.translation
            }
            .recover { error in
                logger.error("Translation error: \(error)")
                return nil
            }
    }
}

private struct WatsonResponse: Decodable {
    let translations: [Translation]
}

private extension WatsonResponse {
    struct Translation: Decodable {
        let translation: String
    }
}
