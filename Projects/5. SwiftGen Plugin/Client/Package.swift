// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Client",
    defaultLocalization: "en",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/ReQEnoxus/swiftgen-spm-plugin.git", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "Client",
            exclude: ["Resources/swiftgen.yml"],
            plugins: [.plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")]
        ),
    ]
)
