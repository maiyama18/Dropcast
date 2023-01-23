// swift-tools-version: 5.7

import PackageDescription

extension PackageDescription.Target.Dependency {
    static let composableArchitecture: Self = .product(
        name: "ComposableArchitecture",
        package: "swift-composable-architecture"
    )
}

let dependencies: [PackageDescription.Package.Dependency] = [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.49.2")
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
    .target(
        name: "FeedFeature",
        dependencies: [.composableArchitecture],
        path: "Sources/Feature/Feed"
    ),
    .target(
        name: "ShowsFeature",
        dependencies: [.composableArchitecture],
        path: "Sources/Feature/Shows"
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
    ],
    dependencies: dependencies,
    targets: targets
)
