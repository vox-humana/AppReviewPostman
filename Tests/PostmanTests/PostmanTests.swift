@testable import Postman
import SnapshotTesting
import XCTest
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class PostmanTests: XCTestCase {
    func testFeedDecoding() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "feed", withExtension: "json"))

        let data = try Data(contentsOf: url)
        let feed = try JSONDecoder().decode(ReviewsFeed.self, from: data)
        let entries = try XCTUnwrap(feed.feed.entry)
        XCTAssertEqual(entries.count, 7)

        let reviews = entries.compactMap(Review.init(feedItem:))

        let template = """
        {{stars}}\n{{message}}\n{{author}}({{country_flag}} {{country}})
        """

        let result = reviews.map { $0.format(template: template, countryCode: .AU, jsonEscaping: false) }
        _assertInlineSnapshot(matching: result, as: .dump, with: #"""
        ▿ 7 elements
          - "★★★★★\nGitHub is by far the best, not only because it’s the only one out there to offer a great mobile app (where you can even browse the source code) but also because its UI is sooo gooood!!!!!\nph7enry(🇦🇺 Australia)"
          - "★☆☆☆☆\nNever used the app.  First time installing it. Straight after it installed I opened it and tried to sign in. I got a error message saying that I triggered an abuse mechanism. Your anti-abuse is too sensitive. In using 4G mobile data with no other devices connected, never used the app before now, and haven’t touched my phone in hours  prior to installing the app, so I don’t know what I could have possibly done to trigger your anti-abuse systems.\n\nMy device is an iPhone Xs Max. Location Chengdu. Network is 4G China Mobile.\nCProetti(🇦🇺 Australia)"
          - "★☆☆☆☆\nHorrible experience. Not usable.\njfhukednyfuru(🇦🇺 Australia)"
          - "★★★★☆\nSo far the app is great for conducting code review in the go. The only issue I have is there is no way to view commit history for a specific branch outside if the pull request UI. If this could be added in a future version that would easily make this app 5 stars.\ntwomedia(🇦🇺 Australia)"
          - "★★★★★\nThanks for having an iPad app!\nI can now review code from the couch, which was a thing I didn’t know I missed from my life.\nDo add the ability to mark files as reviewed, like on web.\njuhan_h(🇦🇺 Australia)"
          - "★★★★★\nI have been waiting for Github to make the move to mobile platforms, I still think there is still more functionality needed, but it’s a great start!\nTydewest(🇦🇺 Australia)"
          - "★★★★★\nWaiting for this for so long!!!!! I can finally interact with my team members on GitHub on the go!\nPlak 13(🇦🇺 Australia)"
        """#)
    }

    func testSingleItemFeedDecoding() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "single_item_feed", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let feed = try JSONDecoder().decode(ReviewsFeed.self, from: data)
        let entries = try XCTUnwrap(feed.feed.entry)
        XCTAssertEqual(entries.count, 1)
    }

    func testEmptyFeedDecoding() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "empty_feed", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let feed = try JSONDecoder().decode(ReviewsFeed.self, from: data)
        XCTAssertNil(feed.feed.entry)
    }

    func testTranslationFormat() throws {
        let template = """
        {{stars}}
        {{#translated_message}}{{{translated_message}}}
        (translated){{/translated_message}}{{^translated_message}}{{{message}}}{{/translated_message}}
        {{{author}}} {{country_flag}}{{country}}
        """

        let review = Review(
            id: 1,
            author: "John\t\"Doe\"",
            message: "Might\\ \"be <better>\"\n🤔",
            rating: 3,
            translatedMessage: nil
        )

        let translated = review.adding(translation: "\">Perfect<\" app\t👌")
        let formatted = { (review: Review, jsonEscaping: Bool) -> String in
            review.format(template: template, countryCode: .SE, jsonEscaping: jsonEscaping)
        }

        do {
            let jsonEscaping = false
            _assertInlineSnapshot(matching: formatted(review, jsonEscaping), as: .description, with: #"""
            ★★★☆☆
            Might\ "be <better>"
            🤔
            John	"Doe" 🇸🇪Sweden
            """#)

            _assertInlineSnapshot(matching: formatted(translated, jsonEscaping), as: .description, with: #"""
            ★★★☆☆
            ">Perfect<" app	👌
            (translated)
            John	"Doe" 🇸🇪Sweden
            """#)
        }

        do {
            let jsonEscaping = true
            _assertInlineSnapshot(matching: formatted(review, jsonEscaping), as: .description, with: #"""
            ★★★☆☆
            Might\\ \"be <better>\"\n🤔
            John\t\"Doe\" 🇸🇪Sweden
            """#)

            _assertInlineSnapshot(matching: formatted(translated, jsonEscaping), as: .description, with: #"""
            ★★★☆☆
            \">Perfect<\" app\t👌
            (translated)
            John\t\"Doe\" 🇸🇪Sweden
            """#)
        }
    }

    func testCountryFlag() {
        let codes = CountryCode.allCases
        let flags = codes.map(\.flag)
        _assertInlineSnapshot(matching: flags, as: .description, with: """
        ["🇦🇫", "🇦🇪", "🇦🇬", "🇦🇮", "🇦🇱", "🇦🇲", "🇦🇴", "🇦🇷", "🇦🇹", "🇦🇺", "🇦🇿", "🇧🇧", "🇧🇪", "🇧🇦", "🇧🇫", "🇧🇬", "🇧🇭", "🇧🇯", "🇧🇲", "🇧🇳", "🇧🇴", "🇧🇷", "🇧🇸", "🇧🇹", "🇧🇼", "🇧🇾", "🇧🇿", "🇨🇲", "🇨🇦", "🇨🇬", "🇨🇭", "🇨🇮", "🇨🇱", "🇨🇳", "🇨🇴", "🇨🇩", "🇨🇷", "🇨🇻", "🇨🇾", "🇨🇿", "🇩🇪", "🇩🇰", "🇩🇲", "🇩🇴", "🇩🇿", "🇪🇨", "🇪🇪", "🇪🇬", "🇪🇸", "🇫🇮", "🇫🇯", "🇫🇲", "🇫🇷", "🇬🇦", "🇬🇧", "🇬🇩", "🇬🇪", "🇬🇭", "🇬🇲", "🇬🇷", "🇬🇹", "🇬🇼", "🇬🇾", "🇭🇰", "🇭🇳", "🇭🇷", "🇭🇺", "🇮🇩", "🇮🇪", "🇮🇱", "🇮🇳", "🇮🇶", "🇮🇸", "🇮🇹", "🇯🇲", "🇯🇴", "🇯🇵", "🇰🇪", "🇰🇬", "🇰🇭", "🇰🇳", "🇰🇷", "🇰🇼", "🇰🇾", "🇰🇿", "🇱🇦", "🇱🇧", "🇱🇾", "🇱🇨", "🇱🇰", "🇱🇷", "🇱🇹", "🇱🇺", "🇱🇻", "🇲🇦", "🇲🇩", "🇲🇻", "🇲🇬", "🇲🇰", "🇲🇱", "🇲🇲", "🇲🇳", "🇲🇪", "🇲🇴", "🇲🇷", "🇲🇸", "🇲🇹", "🇲🇺", "🇲🇼", "🇲🇽", "🇲🇾", "🇲🇿", "🇳🇦", "🇳🇪", "🇳🇬", "🇳🇮", "🇳🇱", "🇳🇴", "🇳🇵", "🇳🇷", "🇳🇿", "🇴🇲", "🇵🇦", "🇵🇪", "🇵🇬", "🇵🇭", "🇵🇰", "🇵🇱", "🇵🇹", "🇵🇼", "🇵🇾", "🇶🇦", "🇷🇴", "🇷🇺", "🇷🇼", "🇸🇦", "🇸🇧", "🇸🇨", "🇸🇪", "🇸🇬", "🇸🇮", "🇸🇰", "🇸🇱", "🇸🇳", "🇸🇷", "🇷🇸", "🇸🇹", "🇸🇻", "🇸🇿", "🇹🇨", "🇹🇩", "🇹🇭", "🇹🇯", "🇹🇲", "🇹🇳", "🇹🇴", "🇹🇷", "🇹🇹", "🇹🇼", "🇹🇿", "🇺🇦", "🇺🇬", "🇺🇸", "🇺🇾", "🇺🇿", "🇻🇨", "🇻🇪", "🇻🇬", "🇻🇳", "🇻🇺", "🇽🇰", "🇾🇪", "🇿🇦", "🇿🇲", "🇿🇼"]
        """)
    }

    func testCountryName() {
        print("Current locale:", Locale.current.identifier)
        let codes = CountryCode.allCases
        let names = codes.compactMap(\.countryName)
        #if os(macOS)
            _assertInlineSnapshot(matching: names, as: .description, with: """
            ["Afghanistan", "United Arab Emirates", "Antigua & Barbuda", "Anguilla", "Albania", "Armenia", "Angola", "Argentina", "Austria", "Australia", "Azerbaijan", "Barbados", "Belgium", "Bosnia & Herzegovina", "Burkina Faso", "Bulgaria", "Bahrain", "Benin", "Bermuda", "Brunei", "Bolivia", "Brazil", "Bahamas", "Bhutan", "Botswana", "Belarus", "Belize", "Cameroon", "Canada", "Congo - Brazzaville", "Switzerland", "Côte d’Ivoire", "Chile", "China mainland", "Colombia", "Congo - Kinshasa", "Costa Rica", "Cape Verde", "Cyprus", "Czechia", "Germany", "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ecuador", "Estonia", "Egypt", "Spain", "Finland", "Fiji", "Micronesia", "France", "Gabon", "United Kingdom", "Grenada", "Georgia", "Ghana", "Gambia", "Greece", "Guatemala", "Guinea-Bissau", "Guyana", "Hong Kong", "Honduras", "Croatia", "Hungary", "Indonesia", "Ireland", "Israel", "India", "Iraq", "Iceland", "Italy", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan", "Cambodia", "St. Kitts & Nevis", "South Korea", "Kuwait", "Cayman Islands", "Kazakhstan", "Laos", "Lebanon", "Libya", "St. Lucia", "Sri Lanka", "Liberia", "Lithuania", "Luxembourg", "Latvia", "Morocco", "Moldova", "Maldives", "Madagascar", "North Macedonia", "Mali", "Myanmar (Burma)", "Mongolia", "Montenegro", "Macao", "Mauritania", "Montserrat", "Malta", "Mauritius", "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "Niger", "Nigeria", "Nicaragua", "Netherlands", "Norway", "Nepal", "Nauru", "New Zealand", "Oman", "Panama", "Peru", "Papua New Guinea", "Philippines", "Pakistan", "Poland", "Portugal", "Palau", "Paraguay", "Qatar", "Romania", "Russia", "Rwanda", "Saudi Arabia", "Solomon Islands", "Seychelles", "Sweden", "Singapore", "Slovenia", "Slovakia", "Sierra Leone", "Senegal", "Suriname", "Serbia", "São Tomé & Príncipe", "El Salvador", "Eswatini", "Turks & Caicos Islands", "Chad", "Thailand", "Tajikistan", "Turkmenistan", "Tunisia", "Tonga", "Turkey", "Trinidad & Tobago", "Taiwan", "Tanzania", "Ukraine", "Uganda", "United States", "Uruguay", "Uzbekistan", "St. Vincent & Grenadines", "Venezuela", "British Virgin Islands", "Vietnam", "Vanuatu", "Kosovo", "Yemen", "South Africa", "Zambia", "Zimbabwe"]
            """)
        #elseif os(Linux)
            _assertInlineSnapshot(matching: names, as: .description, with: """
            ["Afghanistan", "United Arab Emirates", "Antigua & Barbuda", "Anguilla", "Albania", "Armenia", "Angola", "Argentina", "Austria", "Australia", "Azerbaijan", "Barbados", "Belgium", "Bosnia & Herzegovina", "Burkina Faso", "Bulgaria", "Bahrain", "Benin", "Bermuda", "Brunei", "Bolivia", "Brazil", "Bahamas", "Bhutan", "Botswana", "Belarus", "Belize", "Cameroon", "Canada", "Congo - Brazzaville", "Switzerland", "Côte d’Ivoire", "Chile", "China", "Colombia", "Congo - Kinshasa", "Costa Rica", "Cape Verde", "Cyprus", "Czechia", "Germany", "Denmark", "Dominica", "Dominican Republic", "Algeria", "Ecuador", "Estonia", "Egypt", "Spain", "Finland", "Fiji", "Micronesia", "France", "Gabon", "United Kingdom", "Grenada", "Georgia", "Ghana", "Gambia", "Greece", "Guatemala", "Guinea-Bissau", "Guyana", "Hong Kong SAR China", "Honduras", "Croatia", "Hungary", "Indonesia", "Ireland", "Israel", "India", "Iraq", "Iceland", "Italy", "Jamaica", "Jordan", "Japan", "Kenya", "Kyrgyzstan", "Cambodia", "St. Kitts & Nevis", "South Korea", "Kuwait", "Cayman Islands", "Kazakhstan", "Laos", "Lebanon", "Libya", "St. Lucia", "Sri Lanka", "Liberia", "Lithuania", "Luxembourg", "Latvia", "Morocco", "Moldova", "Maldives", "Madagascar", "North Macedonia", "Mali", "Myanmar (Burma)", "Mongolia", "Montenegro", "Macao SAR China", "Mauritania", "Montserrat", "Malta", "Mauritius", "Malawi", "Mexico", "Malaysia", "Mozambique", "Namibia", "Niger", "Nigeria", "Nicaragua", "Netherlands", "Norway", "Nepal", "Nauru", "New Zealand", "Oman", "Panama", "Peru", "Papua New Guinea", "Philippines", "Pakistan", "Poland", "Portugal", "Palau", "Paraguay", "Qatar", "Romania", "Russia", "Rwanda", "Saudi Arabia", "Solomon Islands", "Seychelles", "Sweden", "Singapore", "Slovenia", "Slovakia", "Sierra Leone", "Senegal", "Suriname", "Serbia", "São Tomé & Príncipe", "El Salvador", "Eswatini", "Turks & Caicos Islands", "Chad", "Thailand", "Tajikistan", "Turkmenistan", "Tunisia", "Tonga", "Turkey", "Trinidad & Tobago", "Taiwan", "Tanzania", "Ukraine", "Uganda", "United States", "Uruguay", "Uzbekistan", "St. Vincent & Grenadines", "Venezuela", "British Virgin Islands", "Vietnam", "Vanuatu", "Kosovo", "Yemen", "South Africa", "Zambia", "Zimbabwe"]
            """)
        #endif
    }

    func testAllFeeds() throws {
        // Can't use `async` annotation for test method on Linux
        // https://bugs.swift.org/browse/SR-15230
        let appId = "915056765" // Apple Maps
        let allCountries = CountryCode.allCases
        let expectations = allCountries.map { XCTestExpectation(description: $0.rawValue) }
        Task {
            await withThrowingTaskGroup(of: Void.self, body: { group in
                for i in 0 ..< allCountries.count {
                    group.addTask {
                        let code = allCountries[i]
                        do {
                            _ = try await URLSession.shared.reviews(for: appId, countryCode: code)
                        } catch {
                            XCTFail("\(code) feed request failed \(error)")
                        }
                        expectations[i].fulfill()
                    }
                }
            })
        }
        wait(for: expectations, timeout: 60)
    }
}
