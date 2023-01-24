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
}

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.49.2"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "0.1.4"),
]

let targets: [PackageDescription.Target] = [
    .target(
        name: "App",
        dependencies: ["AppFeature"],
        path: "Sources/App/App"
    ),
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
            "ITunesClient",
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
        name: "ITunesClient",
        dependencies: [
            .dependencies,
            "Entity",
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
        name: "Entity",
        dependencies: [],
        path: "Sources/Core/Entity"
    ),
    .target(
        name: "TestHelper",
        dependencies: [],
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
    ],
    dependencies: dependencies,
    targets: targets
)
