import Foundation
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

extension URLSession {
    func reviews(for appId: String, countryCode: CountryCode) async throws -> [Review] {
        let response: ReviewsFeed = try await value(
            from: URL.reviewFeedURL(for: appId, countryCode: countryCode)
        )
        return response.feed.entry?.compactMap(Review.init(feedItem:)) ?? []
    }
}

private extension URL {
    static func reviewFeedURL(for appId: String, countryCode: CountryCode) -> URL {
        URL(string: "https://itunes.apple.com/\(countryCode.rawValue)/rss/customerreviews/id=\(appId)/sortBy=mostRecent/json")!
    }
}

struct ReviewsFeed: Decodable {
    struct Feed: Decodable {
        struct Entry: Decodable {
            struct EntryLabel: Decodable {
                let label: String
            }

            let author: Author
            struct Author: Decodable {
                let name: EntryLabel
            }

            let title: EntryLabel?
            let content: EntryLabel
            let id: EntryLabel
            let rating: EntryLabel

            enum CodingKeys: String, CodingKey {
                case author
                case title
                case content
                case id
                case rating = "im:rating"
            }
        }

        let entry: [Entry]?

        enum CodingKeys: String, CodingKey {
            case entry
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // Might be an array or a single value :shrug:
            do {
                entry = try container.decodeIfPresent([Entry].self, forKey: .entry)
            } catch {
                guard let singleEntry = try container.decodeIfPresent(Entry.self, forKey: .entry) else {
                    entry = []
                    return
                }
                entry = [singleEntry]
            }
        }
    }

    let feed: Feed
}

extension Review {
    init?(feedItem: ReviewsFeed.Feed.Entry) {
        guard let id = Int(feedItem.id.label) else {
            return nil
        }
        self.id = id
        author = feedItem.author.name.label
        message = feedItem.content.label
        rating = Int(feedItem.rating.label) ?? 0
        translatedMessage = nil
    }
}
