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
    static let customDump: Self = .product(
        name: "CustomDump",
        package: "swift-custom-dump"
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
    static let nukeUI: Self = .product(
        name: "NukeUI",
        package: "Nuke"
    )
}

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms", exact: "0.0.4"),
    .package(url: "https://github.com/kean/Nuke", exact: "11.6.2"),
    .package(url: "https://github.com/nmdias/FeedKit", exact: "9.1.2"),
    .package(url: "https://github.com/omaralbeik/Drops", exact: "1.6.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.49.2"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", exact: "0.8.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "0.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", exact: "0.6.0"),
    .package(url: "https://github.com/realm/SwiftLint", branch: "main"),
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
        path: "Tests/Feature/AppTests"
    ),
    .target(
        name: "FeedFeature",
        dependencies: [
            .composableArchitecture,
            "Components",
            "DatabaseClient",
            "Entity",
            "MessageClient",
            "SoundFileClient",
        ],
        path: "Sources/Feature/Feed"
    ),
    .testTarget(
        name: "FeedFeatureTests",
        dependencies: [
            "FeedFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/FeedTests"
    ),
    .target(
        name: "ShowsFeature",
        dependencies: [
            .composableArchitecture,
            .nukeUI,
            "Entity",
            "Error",
            "ITunesClient",
            "MessageClient",
            "RSSClient",
            "ShowDetailFeature",
        ],
        path: "Sources/Feature/Shows"
    ),
    .testTarget(
        name: "ShowsFeatureTests",
        dependencies: [
            "ShowsFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/ShowsTests"
    ),
    .target(
        name: "ShowDetailFeature",
        dependencies: [
            .composableArchitecture,
            .nukeUI,
            "Components",
            "ClipboardClient",
            "DatabaseClient",
            "Entity",
            "MessageClient",
            "RSSClient",
            "SoundFileClient",
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
        path: "Tests/Feature/ShowDetailTests"
    ),

    // UI module

    .target(
        name: "Components",
        dependencies: [
            .nukeUI,
            "Entity",
            "Formatter",
        ],
        path: "Sources/UI/Components"
    ),

    // Infra module

    .target(
        name: "ClipboardClient",
        dependencies: [.dependencies],
        path: "Sources/Infra/ClipboardClient"
    ),
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
            "Logger",
            "Network",
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
            "Logger",
            "Network",
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
    .target(
        name: "SoundFileClient",
        dependencies: [
            .dependencies,
            "Error",
            "Entity",
        ],
        path: "Sources/Infra/SoundFileClient"
    ),
    .testTarget(
        name: "SoundFileClientTests",
        dependencies: [
            "SoundFileClient",
            "TestHelper",
        ],
        path: "Tests/Infra/SoundFileClientTests"
    ),

    // Core module

    .target(
        name: "Entity",
        dependencies: ["Formatter"],
        path: "Sources/Core/Entity"
    ),
    .target(
        name: "Error",
        dependencies: [],
        path: "Sources/Core/Error"
    ),
    .target(
        name: "Formatter",
        dependencies: [],
        path: "Sources/Core/Formatter"
    ),
    .testTarget(
        name: "FormatterTests",
        dependencies: ["Formatter"],
        path: "Tests/Core/FormatterTests"
    ),
    .target(
        name: "Network",
        dependencies: ["Error"],
        path: "Sources/Core/Network"
    ),
    .testTarget(
        name: "NetworkTests",
        dependencies: [
            "Network",
            "TestHelper",
        ],
        path: "Tests/Core/NetworkTests"
    ),
    .target(
        name: "Logger",
        dependencies: [
            .customDump,
            .dependencies,
        ],
        path: "Sources/Core/Logger"
    ),
    .target(
        name: "TestHelper",
        dependencies: [
            .asyncAlgorithms,
            .customDump,
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
    
    var plugins = target.plugins ?? []
    plugins.append(
        .plugin(name: "SwiftLintPlugin", package: "SwiftLint")
    )
    target.plugins = plugins
    
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
            name: "Components",
            targets: ["Components"]),
        .library(
            name: "DatabaseClient",
            targets: ["DatabaseClient"]),
        .library(
            name: "ITunesClient",
            targets: ["ITunesClient"]),
        .library(
            name: "RSSClient",
            targets: ["RSSClient"]),
        .library(
            name: "SoundFileClient",
            targets: ["SoundFileClient"]),
        .library(
            name: "Formatter",
            targets: ["Formatter"]),
        .library(
            name: "Network",
            targets: ["Network"]),
    ],
    dependencies: dependencies,
    targets: targets
)
