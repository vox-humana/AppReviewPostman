// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AppReviewPostman",
    products: [
        .library(name: "AppReview", targets: ["AppReview"]),
        .executable(name: "Postman", targets: ["Postman"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.33.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.16.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.1"),
        .package(url: "https://github.com/AlwaysRightInstitute/mustache.git", from: "1.0.0"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    ],
    targets: [
        .target(
            name: "AppReview",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
                .product(name: "Logging", package: "swift-log"),
                "mustache",
            ]
        ),
        .executableTarget(
            name: "Postman",
            dependencies: [
                "AppReview",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "AppReviewPostmanTests",
            dependencies: [
                "AppReview",
                "mustache",
                "SnapshotTesting",
            ],
            resources: [
                .copy("feed.json"),
            ]
        ),
    ]
)
