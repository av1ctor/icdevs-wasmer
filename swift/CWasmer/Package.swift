// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CWasmer",
    products: [
        .library(
            name: "CWasmer",
            targets: ["CWasmer"]),
    ],
    dependencies: [
    ],
    targets: [
        .systemLibrary(
            name: "CWasmer",
            pkgConfig: "wasmer"),
    ]
)
