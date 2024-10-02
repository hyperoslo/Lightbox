// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Lightbox",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Lightbox",
            targets: ["Lightbox"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Lightbox",
            dependencies: [],
            path: "Source"
            )
    ],
    swiftLanguageVersions: [.v5]
)
