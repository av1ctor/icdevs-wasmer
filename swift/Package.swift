// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "sw_sw",
    dependencies: [
    ],
    targets: [
        .systemLibrary(
            name: "CWasmer", 
            pkgConfig: "wasmer"),
        .executableTarget(
            name: "sw_sw",
            dependencies: ["CWasmer"],
            resources: [
                .copy("a-motoko-lib.wasm")]
        ),
    ]
)
