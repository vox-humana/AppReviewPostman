import Foundation
import InlineSnapshotTesting
@testable import Postman
import Testing
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

struct ReviewFeedTests {
    @Test func feedDecoding() throws {
        let url = try #require(Bundle.module.url(forResource: "feed", withExtension: "json"))

        let data = try Data(contentsOf: url)
        let feed = try JSONDecoder().decode(ReviewsFeed.self, from: data)
        let entries = try #require(feed.feed.entry)
        #expect(entries.count == 7)

        let reviews = entries.compactMap(Review.init(feedItem:))

        let template = """
        {{stars}}\n{{message}}\n{{author}}({{country_flag}} {{country}})
        """

        let result = reviews.map { $0.format(template: template, countryCode: .AU, jsonEscaping: false) }
        assertInlineSnapshot(of: result, as: .dump) {
            #"""
            ▿ 7 elements
              - "★★★★★\nGitHub is by far the best, not only because it’s the only one out there to offer a great mobile app (where you can even browse the source code) but also because its UI is sooo gooood!!!!!\nph7enry(🇦🇺 Australia)"
              - "★☆☆☆☆\nNever used the app.  First time installing it. Straight after it installed I opened it and tried to sign in. I got a error message saying that I triggered an abuse mechanism. Your anti-abuse is too sensitive. In using 4G mobile data with no other devices connected, never used the app before now, and haven’t touched my phone in hours  prior to installing the app, so I don’t know what I could have possibly done to trigger your anti-abuse systems.\n\nMy device is an iPhone Xs Max. Location Chengdu. Network is 4G China Mobile.\nCProetti(🇦🇺 Australia)"
              - "★☆☆☆☆\nHorrible experience. Not usable.\njfhukednyfuru(🇦🇺 Australia)"
              - "★★★★☆\nSo far the app is great for conducting code review in the go. The only issue I have is there is no way to view commit history for a specific branch outside if the pull request UI. If this could be added in a future version that would easily make this app 5 stars.\ntwomedia(🇦🇺 Australia)"
              - "★★★★★\nThanks for having an iPad app!\nI can now review code from the couch, which was a thing I didn’t know I missed from my life.\nDo add the ability to mark files as reviewed, like on web.\njuhan_h(🇦🇺 Australia)"
              - "★★★★★\nI have been waiting for Github to make the move to mobile platforms, I still think there is still more functionality needed, but it’s a great start!\nTydewest(🇦🇺 Australia)"
              - "★★★★★\nWaiting for this for so long!!!!! I can finally interact with my team members on GitHub on the go!\nPlak 13(🇦🇺 Australia)"

            """#
        }
    }

    @Test func singleItemFeedDecoding() throws {
        let url = try #require(Bundle.module.url(forResource: "single_item_feed", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let feed = try JSONDecoder().decode(ReviewsFeed.self, from: data)
        let entries = try #require(feed.feed.entry)
        #expect(entries.count == 1)
    }

    @Test func emptyFeedDecoding() throws {
        let url = try #require(Bundle.module.url(forResource: "empty_feed", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let feed = try JSONDecoder().decode(ReviewsFeed.self, from: data)
        #expect(feed.feed.entry == nil)
    }

    @Test func allFeeds() async throws {
        let appId = "915056765" // Apple Maps
        let allCountries = CountryCode.allCases

        await withThrowingTaskGroup(of: Void.self, body: { group in
            for i in 0 ..< allCountries.count {
                group.addTask {
                    let code = allCountries[i]
                    do {
                        _ = try await URLSession.shared.reviews(for: appId, countryCode: code)
                    } catch {
                        Issue.record("\(code) feed request failed \(error)")
                    }
                }
            }
        })
    }
}
