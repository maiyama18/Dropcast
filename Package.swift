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
    static let defaults: Self = .product(
        name: "Defaults",
        package: "Defaults"
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

extension PackageDescription.Target.PluginUsage {
    static let swiftlint: Self = .plugin(
        name: "LintCheckBuildToolPlugin",
        package: "SwiftLintPlugins"
    )
    static let swiftgen: Self = .plugin(
        name: "SwiftGenPlugin",
        package: "SwiftGenPlugin"
    )
}

let dependencies: [PackageDescription.Package.Dependency] = [
    // libraries
    .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms", exact: "0.0.4"),
    .package(url: "https://github.com/kean/Nuke", exact: "11.6.2"),
    .package(url: "https://github.com/nmdias/FeedKit", exact: "9.1.2"),
    .package(url: "https://github.com/omaralbeik/Drops", exact: "1.6.1"),
    .package(url: "https://github.com/sindresorhus/Defaults", exact: "7.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.51.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", exact: "0.8.0"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "0.1.4"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", exact: "0.7.0"),

    // plugins
    .package(url: "https://github.com/maiyama18/SwiftLintPlugins", exact: "0.9.3"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", exact: "6.6.2"),
]

let targets: [PackageDescription.Target] = [

    // App module

    .target(
        name: "App",
        dependencies: [
            .dependencies,
            "AppFeature",
            "DebugFeature",
            "MessageClientLive",
            "Logger",
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
        path: "Sources/Feature/AppFeature",
        plugins: [.swiftgen]
    ),
    .testTarget(
        name: "AppFeatureTests",
        dependencies: ["AppFeature"],
        path: "Tests/Feature/AppFeatureTests"
    ),
    .target(
        name: "DebugFeature",
        dependencies: [
            .dependencies,
            "ClipboardClient",
            "Formatter",
            "Logger",
            "MessageClient",
            "SoundFileClient",
        ],
        path: "Sources/Feature/DebugFeature"
    ),
    .target(
        name: "FeedFeature",
        dependencies: [
            .composableArchitecture,
            "Components",
            "DatabaseClient",
            "Entity",
            "MessageClient",
            "RSSClient",
            "SoundFileClient",
            "UserDefaultsClient",
        ],
        path: "Sources/Feature/FeedFeature",
        plugins: [.swiftgen]
    ),
    .testTarget(
        name: "FeedFeatureTests",
        dependencies: [
            "FeedFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/FeedFeatureTests"
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
        path: "Sources/Feature/ShowsFeature",
        plugins: [.swiftgen]
    ),
    .testTarget(
        name: "ShowsFeatureTests",
        dependencies: [
            "ShowsFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/ShowsFeatureTests"
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
        path: "Sources/Feature/ShowDetailFeature",
        plugins: [.swiftgen]
    ),
    .testTarget(
        name: "ShowDetailFeatureTest",
        dependencies: [
            "DatabaseClient",
            "ShowDetailFeature",
            "TestHelper",
        ],
        path: "Tests/Feature/ShowDetailFeatureTests"
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
            "Logger",
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
            "Logger",
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
    .target(
        name: "UserDefaultsClient",
        dependencies: [
            .defaults,
            .dependencies,
            "Build",
        ],
        path: "Sources/Infra/UserDefaultsClient"
    ),

    // Core module

    .target(
        name: "Build",
        dependencies: [],
        path: "Sources/Core/Build"
    ),
    .target(
        name: "Entity",
        dependencies: ["Formatter"],
        path: "Sources/Core/Entity"
    ),
    .target(
        name: "Error",
        dependencies: [],
        path: "Sources/Core/Error",
        plugins: [.swiftgen]
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

    // Plugin module

    .plugin(
        name: "InitLocalizationPlugin",
        capability: .command(
            intent: .custom(verb: "init-localization", description: "Initialize files for localization"),
            permissions: [.writeToPackageDirectory(reason: "Make files for localization")]
        )
    ),
].map { (target: PackageDescription.Target) -> PackageDescription.Target in
    guard target.type != .plugin else { return target }

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
    plugins.append(.swiftlint)
    target.plugins = plugins

    return target
}

var package = Package(
    name: "Dropcast",
    defaultLocalization: "en",
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
