public struct Review {
    public let id: Int
    let author: String
    public let message: String
    let rating: Int
    let translatedMessage: String?
}

extension Review {
    public func adding(translation: String) -> Self {
        .init(
            id: id,
            author: author,
            message: message,
            rating: rating,
            translatedMessage: translation
        )
    }
}
