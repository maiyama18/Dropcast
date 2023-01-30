// swift-tools-version: 5.7

import PackageDescription

extension PackageDescription.Target.Dependency {
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
}

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.49.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "0.1.4"),
    .package(url: "https://github.com/omaralbeik/Drops", exact: "1.6.1"),
    .package(url: "https://github.com/nmdias/FeedKit", exact: "9.1.2"),
]

let targets: [PackageDescription.Target] = [

    // App module

    .target(
        name: "App",
        dependencies: [
            "AppFeature",
            "MessageClientLive",
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

    // Infra module

    .target(
        name: "DatabaseClient",
        dependencies: [
            .dependencies,
            "Entity",
        ],
        path: "Sources/Infra/DatabaseClient"
    ),
    .target(
        name: "DatabaseClientLive",
        dependencies: [
            .dependencies,
            "DatabaseClient",
            "Error",
        ],
        path: "Sources/Infra/DatabaseClientLive"
    ),
    .testTarget(
        name: "DatabaseClientLiveTests",
        dependencies: [
            "DatabaseClientLive",
            "TestHelper",
        ],
        path: "Tests/Infra/DatabaseClientLiveTests"
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
        name: "TestHelper",
        dependencies: [.dependencies],
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
            name: "ITunesClient",
            targets: ["ITunesClient"]),
        .library(
            name: "RSSClient",
            targets: ["RSSClient"]),
        .library(
            name: "DatabaseClientLive",
            targets: ["DatabaseClientLive"]),
    ],
    dependencies: dependencies,
    targets: targets
)
