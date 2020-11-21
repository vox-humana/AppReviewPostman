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

    func mustacheDict(for countryCode: CountryCode, jsonEscaping: Bool) -> [MustacheKeys: Any] {
        var output: [MustacheKeys: String] = [
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

        return jsonEscaping ? output.mapValues(\.jsonValueEscaping) : output
    }
}

extension Review {
    public func format(template: String, countryCode: CountryCode, jsonEscaping: Bool) -> String {
        MustacheParser()
            .parse(string: template)
            .render(object: mustacheDict(for: countryCode, jsonEscaping: jsonEscaping))
    }
}

extension Sequence where Element == Review {
    public func format(template: String, countryCode: CountryCode, jsonEscaping: Bool) -> [String] {
        map { $0.format(template: template, countryCode: countryCode, jsonEscaping: jsonEscaping) }
    }
}

private extension String {
    var jsonValueEscaping: String {
        [
            ("\\", #"\\"#),
            ("\n", #"\n"#),
            ("\t", #"\t"#),
            ("\r", #"\r"#),
            ("\"", #"\""#),
        ]
        .reduce(self) { (result, char) -> String in
            result.replacingOccurrences(of: char.0, with: char.1)
        }
    }
}
