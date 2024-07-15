// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XibMigrationHelper",
    platforms: [.macOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(name: "XibMigrationHelper", targets: ["XibMigrationHelper"])
    ],
    dependencies: [
        .package(path: "IBDecodable"),
//        .package(url: "https://github.com/IBDecodable/IBDecodable", branch: "master"),
        .package(url: "https://github.com/JohnSundell/Files", branch: "master"),
        .package(url: "https://github.com/scottrhoyt/SwiftyTextTable", branch: "master"),
        .package(url: "https://github.com/onevcat/Rainbow", branch: "master"),
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "XibMigrationHelper",
            dependencies: [
                .product(name: "IBDecodable", package: "IBDecodable"),
                .product(name: "Files", package: "Files"),
                .product(name: "SwiftyTextTable", package: "SwiftyTextTable"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        )
    ]
)
