// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Lightbox",
    products: [
        .library(
            name: "Lightbox",
            targets: ["Lightbox"]),
    ],
    dependencies: [
      .package(url: "https://github.com/hyperoslo/Imaginary", .branch("master"))
    ],
    targets: [
        .target(
            name: "Lightbox",
            dependencies: ["Imaginary"],
            path: "Source"
            )
    ],
    swiftLanguageVersions: [.v5]
)
