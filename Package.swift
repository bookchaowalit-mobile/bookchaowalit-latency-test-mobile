// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "LatencyTest",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LatencyTestCore", targets: ["LatencyTestCore"]),
        .library(name: "LatencyTestUI", targets: ["LatencyTestUI"]),
    ],
    targets: [
        // Foundation-only domain logic; no SwiftUI so it also builds on Linux.
        .target(name: "LatencyTestCore", path: "Sources/LatencyTestCore"),
        .target(name: "LatencyTestUI", dependencies: ["LatencyTestCore"], path: "Sources/LatencyTestUI"),
        .testTarget(name: "LatencyTestCoreTests", dependencies: ["LatencyTestCore"], path: "Tests/LatencyTestCoreTests"),
    ]
)
