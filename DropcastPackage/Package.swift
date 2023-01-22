// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DropcastPackage",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "App",
            targets: ["App"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "App",
            dependencies: []),
    ]
)
