@testable import Postman
import SnapshotTesting
import XCTest

final class FormattingTests: XCTestCase {
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
}
