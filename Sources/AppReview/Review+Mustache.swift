import mustache

extension Review {
    public enum MustacheKeys: String, CaseIterable {
        case author
        case country
        case country_flag
        case message
        case translated_message
        case stars
    }
}

extension Review {
    private var stars: String {
        let maxRating = 5
        let clamped = max(1, min(rating, maxRating))
        return String(repeating: "★", count: clamped) + String(repeating: "☆", count: maxRating - clamped)
    }

    func mustacheDict(for countryCode: String) -> [MustacheKeys: Any] {
        var output: [MustacheKeys: Any] = [
            .author: author,
            .message: message,
            .stars: stars,
        ]
        if let translation = translatedMessage {
            output[.translated_message] = translation
        }
        if let flag = flag(country: countryCode) {
            output[.country_flag] = flag
        }
        if let country = countryName(from: countryCode) {
            output[.country] = country
        }
        return output
    }
}

extension Sequence where Element == Review {
    public func format(template: String, countryCode: String) -> [String] {
        let tree = MustacheParser().parse(string: template)
        return map { $0.mustacheDict(for: countryCode) }
            .map(tree.render(object:))
    }
}
