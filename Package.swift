// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Latency Test",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Latency Test", targets: ["Latency Test"])
    ],
    targets: [
        .target(name: "Latency Test", path: "Sources")
    ]
)
