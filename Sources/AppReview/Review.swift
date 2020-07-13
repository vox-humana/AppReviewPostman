public struct Review {
    public let id: Int
    let author: String
    let message: String
    let rating: Int
}

extension Review {
    private var stars: String {
        let maxRating = 5
        let clamped = max(1, min(rating, maxRating))
        return String(repeating: "★", count: clamped) + String(repeating: "☆", count: maxRating - clamped)
    }

    func mustacheDict(for countryCode: String) -> [String: Any] {
        [
            "author": author,
            "contry_flag": flag(country: countryCode) ?? "🏴‍☠️",
            "country": countryName(from: countryCode) ?? "Sea Shepherd",
            "message": message,
            "stars": stars,
        ]
    }
}
