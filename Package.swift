// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OctopusSpy",
    products: [
        .executable(name: "octopusspy", targets: ["OctopusSpy"]),
        .library(name: "OctopusSpyKit", targets: ["OctopusSpyKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", .upToNextMajor(from: "4.0.6")),
        .package(url: "https://github.com/onevcat/Rainbow", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/JohnSundell/Files", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "0.4.0")),
        .package(name: "Promises", url: "https://github.com/google/promises.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "OctopusSpy",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "OctopusSpyKit"
            ],
            path: "Sources/OctopusSpy"
        ),
        .target(
            name: "OctopusSpyKit",
            dependencies: [
                .product(name: "Files", package: "Files"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Rainbow", package: "Rainbow"),
                "Promises"
            ],
            path: "Sources/OctopusSpyKit"
        ),
        .testTarget(
            name: "OctopusSpyKitTests",
            dependencies: ["OctopusSpyKit"]),
    ]
)
