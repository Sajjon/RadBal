// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RadBal",
	platforms: [.macOS(.v13)],
	dependencies: [
		.package(url: "https://github.com/attaswift/BigInt", from: "5.3.0"),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "RadBal",
			dependencies: [
				"BigInt"
			],
            path: "Sources"),
    ]
)
