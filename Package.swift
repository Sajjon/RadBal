// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RadBal",
	platforms: [.macOS(.v13), .iOS(.v16)],
	products: [
		.library(
			name: "AppFeature",
			targets: ["AppFeature"]),
	],
    dependencies: [
		.package(url: "https://github.com/leif-ibsen/BigDecimal", from: "1.1.1"),
    ],
    targets: [
		.target(name: "Backend", dependencies: ["BigDecimal"]),
		.target(name: "AppFeature", dependencies: ["Backend"]),
        .executableTarget(
            name: "CLI",
            dependencies: [
				"Backend",
            ]
        ),
    ]
)
