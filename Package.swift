// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LineChartKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "LineChartKit",
            targets: ["LineChartKit"]
        )
    ],
    targets: [
        .target(
            name: "LineChartKit",
            path: "Sources/LineChartKit"
        )
    ]
)
