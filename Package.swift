// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "BartenderClone",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "BartenderClone",
            dependencies: [],
            path: "Sources"
        )
    ]
)
