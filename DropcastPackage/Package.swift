// swift-tools-version: 5.7

import PackageDescription

extension PackageDescription.Target.Dependency {
    static let composableArchitecture: Self = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
}

let package = Package(
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
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.49.2")
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                "FeatureApp",
            ]),
        .target(
            name: "FeatureApp",
            dependencies: [
                .composableArchitecture,
                "FeatureFeed",
                "FeatureShows",
            ]),
        .target(
            name: "FeatureFeed",
            dependencies: [
                .composableArchitecture,
            ]),
        .target(
            name: "FeatureShows",
            dependencies: [
                .composableArchitecture,
            ]),
    ]
)
