// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OnboardingKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "OnboardingKit",
            targets: ["OnboardingKit"]
        ),
        .library(
            name: "OnboardingKitCore",
            targets: ["OnboardingKitCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OnboardingKitCore",
            dependencies: [],
            path: "Sources/OnboardingKitCore"
        ),
        .target(
            name: "OnboardingKit",
            dependencies: ["OnboardingKitCore"],
            path: "Sources/OnboardingKit"
        ),
        .testTarget(
            name: "OnboardingKitTests",
            dependencies: ["OnboardingKit", "OnboardingKitCore"],
            path: "Tests/OnboardingKitTests"
        ),
    ]
)
