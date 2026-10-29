 // swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Alonear",
    products: [
        .library(
            name: "AlonearDSP",
            targets: ["AlonearDSP"]
        )
    ],
    targets: [
        .target(name: "AlonearDSP"),
        .testTarget(
            name: "AlonearDSPTests",
            dependencies: ["AlonearDSP"]
        )
    ]
)
