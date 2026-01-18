// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "OpenBartender",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "OpenBartender",
            dependencies: [],
            path: "Sources"
        )
    ]
)
