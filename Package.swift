// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SdkPaymentsNetcetera",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "SdkPaymentsNetcetera",
            targets: ["SdkPaymentsNetceteraWrapper"]
        )
    ],
    targets: [
        // Wrapper target. Holds the binaries together so a single library
        // product can pull both SdkPaymentsNetcetera and ThreeDS_SDK into the
        // merchant's link line. Also a place to attach linkerSettings if
        // ThreeDS_SDK ends up requiring system frameworks. Same pattern as
        // FirebaseAnalyticsWrapper.
        .target(
            name: "SdkPaymentsNetceteraWrapper",
            dependencies: [
                "SdkPaymentsNetcetera",
                "ThreeDS_SDK"
            ],
            path: "SdkPaymentsNetceteraWrapper",
            publicHeadersPath: "include"
        ),
        .binaryTarget(
            name: "SdkPaymentsNetcetera",
            url: "https://github.com/yuno-payments/yuno-3DS-netcetera-iOS/releases/download/3.0.0-alpha.2/SdkPaymentsNetcetera.xcframework.zip",
            checksum: "4d702b0246a004a78d86a8be4fc655246a4636397d0f9680301bac27fbff151f"
        ),
        .binaryTarget(
            name: "ThreeDS_SDK",
            url: "https://nexus.extranet.netcetera.biz/nexus/repository/public-repository-maven/com/netcetera/nca-341-2/3ds-sdk/ios/release/2.6.01/ThreeDS_SDK.zip",
            checksum: "90284f80dbad0258687d39a724d967f53d47db99cf4bfc3faaeee1fbe9671e2a"
        )
    ]
)
