// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FocusDive",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "FocusDiveCore", targets: ["FocusDiveCore"]),
        .executable(name: "FocusDive", targets: ["FocusDiveApp"])
    ],
    targets: [
        .target(name: "FocusDiveCore"),
        .executableTarget(
            name: "FocusDiveApp",
            dependencies: ["FocusDiveCore"]
        ),
        .testTarget(
            name: "FocusDiveCoreTests",
            dependencies: ["FocusDiveCore"]
        )
    ]
)
