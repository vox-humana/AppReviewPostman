import Foundation

public struct ReviewsFeed: Decodable {
    let feed: Feed
    struct Feed: Decodable {
        let entry: [Entry]
        struct Entry: Decodable {
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
    }
}

struct EntryLabel: Decodable {
    let label: String
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
    }
}
