// swift-tools-version: 5.7

import PackageDescription

extension PackageDescription.Target.Dependency {
    static let algorithms: Self = .product(
        name: "Algorithms",
        package: "swift-algorithms"
    )
    static let asyncAlgorithms: Self = .product(
        name: "AsyncAlgorithms",
        package: "swift-async-algorithms"
    )
    static let composableArchitecture: Self = .product(
        name: "ComposableArchitecture",
        package: "swift-composable-architecture"
    )
    static let dependencies: Self = .product(
        name: "Dependencies",
        package: "swift-dependencies"
    )
    static let drops: Self = .product(
        name: "Drops",
        package: "Drops"
    )
    static let feedKit: Self = .product(
        name: "FeedKit",
        package: "FeedKit"
    )
    static let identifiedCollections: Self = .product(
        name: "IdentifiedCollections",
        package: "swift-identified-collections"
    )
}

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms", exact: "0.0.4"),
    .package(url: "https://github.com/nmdias/FeedKit", exact: "9.1.2"),
    .package(url: "https://github.com/omaralbeik/Drops", exact: "1.6.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.49.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "0.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", exact: "0.6.0"),
]

let targets: [PackageDescription.Target] = [

    // App module

    .target(
        name: "App",
        dependencies: [
            "AppFeature",
            "MessageClientLive",
            "ScreenProviderLive",
        ],
        path: "Sources/App/App"
    ),

    // Feature module

    .target(
        name: "AppFeature",
        dependencies: [
            .composableArchitecture,
            "FeedFeature",
            "ShowsFeature",
        ],
        path: "Sources/Feature/App"
    ),
    .testTarget(
        name: "AppFeatureTests",
        dependencies: ["AppFeature"],
        path: "Tests/Feature/App"
    ),
    .target(
        name: "FeedFeature",
        dependencies: [.composableArchitecture],
        path: "Sources/Feature/Feed"
    ),
    .target(
        name: "ShowsFeature",
        dependencies: [
            .composableArchitecture,
            "Entity",
            "Error",
            "ITunesClient",
            "MessageClient",
            "RSSClient",
            "ScreenProvider",
        ],
        path: "Sources/Feature/Shows"
    ),
    .testTarget(
        name: "ShowsFeatureTests",
        dependencies: [
            "ShowsFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/Shows"
    ),
    .target(
        name: "ShowDetailFeature",
        dependencies: [
            .composableArchitecture,
            "DatabaseClient",
            "Entity",
            "MessageClient",
            "RSSClient",
        ],
        path: "Sources/Feature/ShowDetail"
    ),
    .testTarget(
        name: "ShowDetailFeatureTest",
        dependencies: [
            "DatabaseClient",
            "ShowDetailFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/ShowDetail"
    ),

    // Infra module

    .target(
        name: "DatabaseClient",
        dependencies: [
            .algorithms,
            .asyncAlgorithms,
            .dependencies,
            .identifiedCollections,
            "Entity",
            "Error",
        ],
        path: "Sources/Infra/DatabaseClient"
    ),
    .testTarget(
        name: "DatabaseClientTests",
        dependencies: [
            "DatabaseClient",
            "TestHelper",
        ],
        path: "Tests/Infra/DatabaseClientTests"
    ),
    .target(
        name: "RSSClient",
        dependencies: [
            .dependencies,
            .feedKit,
            "Entity",
            "Error",
        ],
        path: "Sources/Infra/RSSClient"
    ),
    .testTarget(
        name: "RSSClientTests",
        dependencies: [
            "RSSClient",
            "TestHelper",
        ],
        path: "Tests/Infra/RSSClientTests",
        resources: [.process("Resources")]
    ),
    .target(
        name: "ITunesClient",
        dependencies: [
            .dependencies,
            "Entity",
            "Error",
        ],
        path: "Sources/Infra/ITunesClient"
    ),
    .testTarget(
        name: "ITunesClientTests",
        dependencies: [
            "ITunesClient",
            "TestHelper",
        ],
        path: "Tests/Infra/ITunesClientTests",
        resources: [.process("Resources")]
    ),
    .target(
        name: "MessageClient",
        dependencies: [.dependencies],
        path: "Sources/Infra/MessageClient"
    ),
    .target(
        name: "MessageClientLive",
        dependencies: [
            .dependencies,
            .drops,
            "MessageClient",
        ],
        path: "Sources/Infra/MessageClientLive"
    ),

    // Core module

    .target(
        name: "Entity",
        dependencies: [],
        path: "Sources/Core/Entity"
    ),
    .target(
        name: "Error",
        dependencies: [],
        path: "Sources/Core/Error"
    ),
    .target(
        name: "ScreenProvider",
        dependencies: [.dependencies],
        path: "Sources/Core/ScreenProvider"
    ),
    .target(
        name: "ScreenProviderLive",
        dependencies: [
            "ScreenProvider",
            "ShowDetailFeature",
        ],
        path: "Sources/Core/ScreenProviderLive"
    ),
    .target(
        name: "TestHelper",
        dependencies: [
            .asyncAlgorithms,
            .dependencies,
        ],
        path: "Sources/Core/TestHelper"
    ),
].map { (target: PackageDescription.Target) -> PackageDescription.Target in
    var swiftSettings = target.swiftSettings ?? []
    swiftSettings.append(
        .unsafeFlags(
            [
                "-strict-concurrency=complete",
                "-enable-actor-data-race-checks",
            ],
            .when(configuration: .debug)
        )
    )
    target.swiftSettings = swiftSettings
    return target
}

var package = Package(
    name: "DropcastPackage",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "App",
            targets: ["App"]),
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]),
        .library(
            name: "FeedFeature",
            targets: ["FeedFeature"]),
        .library(
            name: "ShowsFeature",
            targets: ["ShowsFeature"]),
        .library(
            name: "ShowDetailFeature",
            targets: ["ShowDetailFeature"]),
        .library(
            name: "ITunesClient",
            targets: ["ITunesClient"]),
        .library(
            name: "RSSClient",
            targets: ["RSSClient"]),
        .library(
            name: "DatabaseClient",
            targets: ["DatabaseClient"]),
    ],
    dependencies: dependencies,
    targets: targets
)
