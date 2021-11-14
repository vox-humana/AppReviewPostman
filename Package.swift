// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AppReviewPostman",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        .executable(name: "Postman", targets: ["Postman"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.1"),
        .package(url: "https://github.com/AlwaysRightInstitute/mustache.git", from: "1.0.0"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    ],
    targets: [
        .executableTarget(
            name: "Postman",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "mustache",
            ]
        ),
        .testTarget(
            name: "PostmanTests",
            dependencies: [
                "Postman",
                "SnapshotTesting",
            ],
            resources: [
                .copy("feed.json"),
                .copy("single_item_feed.json"),
                .copy("empty_feed.json"),
            ]
        ),
    ]
)
