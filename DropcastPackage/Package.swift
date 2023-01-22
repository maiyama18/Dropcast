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
        dependencies: ["FeatureApp"]),
    .target(
        name: "FeatureApp",
        dependencies: [
            .composableArchitecture,
            "FeatureFeed",
            "FeatureShows",
        ]),
    .target(
        name: "FeatureFeed",
        dependencies: [.composableArchitecture]),
    .target(
        name: "FeatureShows",
        dependencies: [.composableArchitecture]),
].map { (target: PackageDescription.Target) -> PackageDescription.Target in
    var swiftSettings = target.swiftSettings ?? []
    swiftSettings.append(
        .unsafeFlags(
            ["-strict-concurrency=complete", "-enable-actor-data-race-checks"],
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
            name: "FeatureApp",
            targets: ["FeatureApp"]),
        .library(
            name: "FeatureFeed",
            targets: ["FeatureFeed"]),
        .library(
            name: "FeatureShows",
            targets: ["FeatureShows"]),
    ],
    dependencies: dependencies,
    targets: targets
)
