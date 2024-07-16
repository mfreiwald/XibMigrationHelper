// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XibMigrationHelper",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "XibMigrationHelper", targets: ["XibMigrationHelper"])
    ],
    dependencies: [
        .package(url: "https://github.com/mfreiwald/IBDecodable", branch: "xib-migration"),
        .package(url: "https://github.com/JohnSundell/Files", branch: "master"),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable", branch: "master"),
        .package(url: "https://github.com/onevcat/Rainbow", branch: "master"),
        .package(url: "https://github.com/pakLebah/ANSITerminal", branch: "master"),
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "XibMigrationHelper",
            dependencies: [
                .product(name: "IBDecodable", package: "IBDecodable"),
                .product(name: "Files", package: "Files"),
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "ANSITerminal", package: "ANSITerminal"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
