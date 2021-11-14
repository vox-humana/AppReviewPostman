struct Review {
    let id: Int
    let author: String
    let message: String
    let rating: Int
    let translatedMessage: String?
}

extension Review {
    func adding(translation: String) -> Self {
        .init(
            id: id,
            author: author,
            message: message,
            rating: rating,
            translatedMessage: translation
        )
    }
}
