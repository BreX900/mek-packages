// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mek_stripe_terminal",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "mek-stripe-terminal", targets: ["mek_stripe_terminal"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),

        .package(
            url: "https://github.com/stripe/stripe-terminal-ios.git",
            from: "5.6.0"
        )
    ],
    targets: [
        .target(
            name: "mek_stripe_terminal",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),

                .product(name: "StripeTerminal", package: "stripe-terminal-ios")
            ],
            resources: [
                // TODO: If your plugin requires a privacy manifest
                // (e.g. if it uses any required reason APIs), update the PrivacyInfo.xcprivacy file
                // to describe your plugin's privacy impact, and then uncomment this line.
                // For more information, visit:
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),

                // TODO: If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
