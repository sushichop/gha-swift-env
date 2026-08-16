// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GHASwiftEnv",
    products: [
        .library(name: "GHASwiftEnv", targets: ["GHASwiftEnv"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "GHASwiftEnv", dependencies: [], exclude: ["CMakeLists.txt"]),
        .testTarget(name: "GHASwiftEnvTests", dependencies: ["GHASwiftEnv"]),
    ],
    swiftLanguageModes: [.v6]
)
