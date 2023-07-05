// swift-tools-version: 5.7

import PackageDescription

let dependencies: [PackageDescription.Package.Dependency] = [
    // libraries
    .package(url: "https://github.com/apple/swift-algorithms", exact: "1.0.0"),
    .package(url: "https://github.com/apple/swift-async-algorithms", exact: "0.0.4"),
    .package(url: "https://github.com/kean/Nuke", exact: "11.6.2"),
    .package(url: "https://github.com/nmdias/FeedKit", exact: "9.1.2"),
    .package(url: "https://github.com/noppefoxwolf/DebugMenu", exact: "2.0.5"),
    .package(url: "https://github.com/omaralbeik/Drops", exact: "1.6.1"),
    .package(url: "https://github.com/sindresorhus/Defaults", exact: "7.1.0"),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", exact: "0.10.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "0.4.2"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", exact: "0.7.1"),

    // plugins
    .package(url: "https://github.com/maiyama18/SwiftLintPlugins", exact: "0.9.4"),
    .package(url: "https://github.com/maiyama18/LicensesPlugin", exact: "0.1.5"),
    .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", exact: "6.6.2"),
]

extension PackageDescription.Target.Dependency {
    static let algorithms: Self = .product(
        name: "Algorithms",
        package: "swift-algorithms"
    )
    static let asyncAlgorithms: Self = .product(
        name: "AsyncAlgorithms",
        package: "swift-async-algorithms"
    )
    static let customDump: Self = .product(
        name: "CustomDump",
        package: "swift-custom-dump"
    )
    static let debugMenu: Self = .product(
        name: "DebugMenu",
        package: "DebugMenu"
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
    static let licenses: Self = .plugin(
        name: "LicensesPlugin",
        package: "LicensesPlugin"
    )
}

let targets: [PackageDescription.Target] = [

    // App module

    .target(
        name: "iOSApp",
        dependencies: [
            "DebugFeature",
            "FeedFeature",
            "MainTabFeature",
            "SettingsFeature",
            "ShowDetailFeature",
            "ShowListFeature",
            "MessageClientLive",
            "Logger",
            "ViewFactory",
            "ScreenTransitionCoordinator",
        ],
        path: "Sources/App/iOSApp"
    ),

    // Feature module

    .target(
        name: "MainTabFeature",
        dependencies: [
            "FeedFeature",
            "ShowListFeature",
            "SettingsFeature",
            "ViewFactory",
        ],
        path: "Sources/Feature/MainTabFeature",
        plugins: [.swiftgen]
    ),
    .target(
        name: "DebugFeature",
        dependencies: [
            .debugMenu,
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
            "ShowDetailFeature",
            "Components",
            "DatabaseClient",
            "DeepLink",
            "Entity",
            "MessageClient",
            "RSSClient",
            "SoundFileClient",
            "UserDefaultsClient",
            "Extension",
        ],
        path: "Sources/Feature/FeedFeature",
        plugins: [.swiftgen]
    ),
    .target(
        name: "SettingsFeature",
        dependencies: [
            "Build",
            "Extension",
        ],
        path: "Sources/Feature/SettingsFeature",
        plugins: [
            .licenses,
            .swiftgen,
        ]
    ),
    .target(
        name: "ShowListFeature",
        dependencies: [
            .nukeUI,
            "ShowDetailFeature",
            "Entity",
            "Error",
            "DatabaseClient",
            "ITunesClient",
            "MessageClient",
            "RSSClient",
            "ScreenTransitionCoordinator",
        ],
        path: "Sources/Feature/ShowListFeature",
        plugins: [.swiftgen]
    ),
    .target(
        name: "ShowDetailFeature",
        dependencies: [
            .nukeUI,
            "Components",
            "ClipboardClient",
            "DatabaseClient",
            "MessageClient",
            "RSSClient",
            "SoundFileClient",
            "Extension",
            "Entity",
        ],
        path: "Sources/Feature/ShowDetailFeature",
        plugins: [.swiftgen]
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
    .target(
        name: "ScreenTransitionCoordinator",
        dependencies: [
            .asyncAlgorithms,
            .dependencies,
        ],
        path: "Sources/UI/ScreenTransitionCoordinator"
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
        name: "DeepLink",
        dependencies: [
            "Environment"
        ],
        path: "Sources/Core/DeepLink"
    ),
    .target(
        name: "Entity",
        dependencies: ["Formatter"],
        path: "Sources/Core/Entity"
    ),
    .target(
        name: "Environment",
        dependencies: [.dependencies],
        path: "Sources/Core/Environment"
    ),
    .target(
        name: "Extension",
        dependencies: [.dependencies],
        path: "Sources/Core/Extension"
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
    .target(
        name: "ViewFactory",
        dependencies: [
            .dependencies,
            "Entity",
        ],
        path: "Sources/Core/ViewFactory"
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
            name: "iOSApp",
            targets: ["iOSApp"]),
        .library(
            name: "MainTabFeature",
            targets: ["MainTabFeature"]),
        .library(
            name: "FeedFeature",
            targets: ["FeedFeature"]),
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]),
        .library(
            name: "ShowListFeature",
            targets: ["ShowListFeature"]),
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
        .library(
            name: "ViewFactory",
            targets: ["ViewFactory"]),
    ],
    dependencies: dependencies,
    targets: targets
)
