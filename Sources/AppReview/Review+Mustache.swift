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

    func mustacheDict(for countryCode: CountryCode) -> [MustacheKeys: Any] {
        var output: [MustacheKeys: Any] = [
            .author: author,
            .message: message,
            .stars: stars,
            .country_flag: countryCode.flag,
        ]
        if let translation = translatedMessage {
            output[.translated_message] = translation
        }
        if let country = countryCode.countryName {
            output[.country] = country
        }
        return output
    }
}

extension Sequence where Element == Review {
    public func format(template: String, countryCode: CountryCode) -> [String] {
        let tree = MustacheParser().parse(string: template)
        return map { $0.mustacheDict(for: countryCode) }
            .map(tree.render(object:))
    }
}
