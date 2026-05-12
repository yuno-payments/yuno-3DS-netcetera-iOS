// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Yuno3DSNetcetera",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Yuno3DSNetcetera",
            type: .dynamic,
            targets: ["Yuno3DSNetceteraWrapper"]
        )
    ],
    targets: [
        // Wrapper target. Holds the binaries together so a single library
        // product can pull both Yuno3DSNetcetera and ThreeDS_SDK into the
        // merchant's link line. Also a place to attach linkerSettings if
        // ThreeDS_SDK ends up requiring system frameworks. Same pattern as
        // FirebaseAnalyticsWrapper.
        .target(
            name: "Yuno3DSNetceteraWrapper",
            dependencies: [
                "Yuno3DSNetcetera",
                "ThreeDS_SDK"
            ],
            path: "Yuno3DSNetceteraWrapper",
            publicHeadersPath: "include"
        ),
        .binaryTarget(
            name: "Yuno3DSNetcetera",
            url: "https://github.com/yuno-payments/yuno-3DS-netcetera-iOS/releases/download/1.0.0/Yuno3DSNetcetera.xcframework.zip",
            checksum: "5c22f4e3f31a08f6a380eb6b3a29bb6378ae4eaecf2ea25feb58e8d5a71a7cd1"
        ),
        .binaryTarget(
            name: "ThreeDS_SDK",
            url: "https://nexus.extranet.netcetera.biz/nexus/repository/public-repository-maven/com/netcetera/nca-341-2/3ds-sdk/ios/release/2.6.01/ThreeDS_SDK.zip",
            checksum: "90284f80dbad0258687d39a724d967f53d47db99cf4bfc3faaeee1fbe9671e2a"
        )
    ]
)
