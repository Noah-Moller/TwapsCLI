// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TwapsDemo",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "TwapsDemo",
            targets: ["TwapsDemo"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "TwapsDemo",
            dependencies: [
                .product(name: "Twaps", package: "TwapsCLI")
            ],
            path: ".")
    ]
) 