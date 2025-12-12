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
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.12.0"
        )
    ],
    targets: [
        .target(
            name: "NotificationCenterFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NotificationCenterFeatureTests",
            dependencies: [
                "NotificationCenterFeature"
            ],
            path: "Tests"
        )
    ]
)
