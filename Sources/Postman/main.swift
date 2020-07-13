import AppReview
import ArgumentParser
import Foundation
import NIO

let group = MultiThreadedEventLoopGroup(numberOfThreads: 4)
defer {
    try! group.syncShutdownGracefully()
}

typealias SentStorage = [String: Int]

struct GetFeed: ParsableCommand {
    @Argument(help: "App identifier to get feed for")
    var appId: String

    @Option(help: "Comma-separated list of country codes")
    var countries: String?

    @Option(help: "Mustache template for formatting reviews")
    var template: String

    @Option(help: "Callback URL where a review will be posted to")
    var postURL: String

    @Option(help: "Last sent review file path")
    var storageFile: String?

    mutating func run() throws {
        let codes = (countries ?? allAppStoreCountries).components(separatedBy: ",")
        guard let url = URL(string: postURL) else {
            print("Wrong URL format")
            return
        }

        let storageURL = storageFile.map(URL.init(fileURLWithPath:))
        var storage = storageURL
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? JSONDecoder().decode(SentStorage.self, from: $0) }
            ?? [:]

        let futures = try codes.map { code in
            try Job(
                appId: appId,
                countryCode: code,
                mustacheTemplate: template,
                postURL: url
            )
            .run(group: group, lastReviewId: storage[code] ?? 0)
            .always { _ in
                print("Done \(code)")
            }
            .map { id in
                (code, id)
            }
        }

        let results = try EventLoopFuture.whenAllComplete(futures, on: group.next()).wait()
        results.forEach { result in
            if case let .success(tupple) = result {
                let (code, id) = tupple
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

GetFeed.main()
