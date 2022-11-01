// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PrepCoreDataStack",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PrepCoreDataStack",
            targets: ["PrepCoreDataStack"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pxlshpr/PrepDataTypes", from: "0.0.49"),
        .package(url: "https://github.com/pxlshpr/SwiftSugar", from: "0.0.77"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PrepCoreDataStack",
            dependencies: [
                .product(name: "PrepDataTypes", package: "prepdatatypes"),
                .product(name: "SwiftSugar", package: "swiftsugar"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "PrepCoreDataStackTests",
            dependencies: ["PrepCoreDataStack"]),
    ]
)
