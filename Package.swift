// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleAIServer",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "AppleAIServer",
            path: "Sources"
        )
    ]
)
