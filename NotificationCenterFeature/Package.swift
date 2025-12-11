// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NotificationCenterFeature",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NotificationCenterFeature",
            targets: ["NotificationCenterFeature"]
        )
    ],
    targets: [
        .target(
            name: "NotificationCenterFeature",
            path: "Sources"
        ),
        .testTarget(
            name: "NotificationCenterFeatureTests",
            dependencies: ["NotificationCenterFeature"],
            path: "Tests"
        )
    ]
)
