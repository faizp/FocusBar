// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FocusBar",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "FocusBar",
            path: "FocusBar",
            exclude: ["Info.plist", "FocusBar.entitlements"],
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
