import AppReview
import ArgumentParser
import Foundation
import Logging
import NIO

#if DEBUG
    let logLevel: Logger.Level = .debug
#else
    let logLevel: Logger.Level = .info
#endif

AppReview.logger.logLevel = logLevel
let logger: Logger = {
    var logger = Logger(label: "com.github.vox-humana.AppReviewPostman.Postman")
    logger.logLevel = logLevel
    return logger
}()

let group = MultiThreadedEventLoopGroup(numberOfThreads: 4)
defer {
    try! group.syncShutdownGracefully()
}

typealias SentStorage = [CountryCode: Int]

struct Postman: ParsableCommand {
    @Argument(help: "App identifier")
    var appId: String

    @Option(
        help: """
        Comma-separated list of two-letter country codes according to 'ISO 3166-1 alpha-2' 
        (default: all countries)
        """,
        transform: CountryCode.codes(from:)
    )
    var countries: [CountryCode]?

    @Option(
        help: """
        Mustache template for formatting reviews. 
        Supported keys: \(Review.MustacheKeys.allSupportedKeys)
        """
    )
    var template: String

    @Option(help: "Callback url for sending formatted messages")
    var postURL: URL

    @Option(help: "Last sent reviews file path")
    var storageFile: String?

    @Option(
        help: "IBM Language Translator url and apikey in {url},{apikey} format",
        transform: Job.Watson.init(string:)
    )
    var translator: Job.Watson?

    mutating func run() throws {
        let storageURL = storageFile.map(URL.init(fileURLWithPath:))
        var storage = storageURL
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode(SentStorage.self, from: $0) }
            ?? [:]

        let futures = try (countries ?? CountryCode.allCases).map { code in
            try Job(
                appId: appId,
                countryCode: code,
                mustacheTemplate: template,
                postURL: postURL,
                translator: translator
            )
            .run(group: group, lastReviewId: storage[code] ?? 0)
            .map { id in
                (code, id)
            }
        }

        let results = try EventLoopFuture.whenAllComplete(futures, on: group.next()).wait()
        results.forEach { result in
            if case let .success((code, id)) = result {
                storage[code] = id
            }
        }

        if let fileURL = storageURL {
            let encoder = JSONEncoder()
            if #available(OSX 10.13, *) {
                encoder.outputFormatting = .sortedKeys
            }
            let output = try? encoder.encode(storage)
            try output?.write(to: fileURL)
        }
    }
}

Postman.main()

// MARK: -

private extension Review.MustacheKeys {
    static var allSupportedKeys: String {
        Self.allCases.map(\.rawValue).joined(separator: ", ")
    }
}

extension URL: ExpressibleByArgument {
    public init?(argument: String) {
        self.init(string: argument)
    }
}

private extension Job.Watson {
    init(string: String) throws {
        let values = string.components(separatedBy: ",")
        guard values.count == 2, let url = URL(string: values[0]) else {
            throw ValidationError("Not a valid value for 'url, apiKey' format")
        }
        self.init(url: url, apikey: values[1])
    }
}

private extension CountryCode {
    static func codes(from string: String) throws -> [CountryCode] {
        try string
            .components(separatedBy: ",")
            .map { $0.uppercased() }
            .map { code -> CountryCode in
                guard let v = CountryCode(rawValue: code) else {
                    throw ValidationError("Unsupported country code \(code)")
                }
                return v
            }
    }
}
