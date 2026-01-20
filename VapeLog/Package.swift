// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VapeLog",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "VapeLog",
            targets: ["VapeLog"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.24.0")
    ],
    targets: [
        .target(
            name: "VapeLog",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources/VapeLog",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
