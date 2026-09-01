// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Yuno3DSNetcetera",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Yuno3DSNetcetera",
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
            url: "https://github.com/yuno-payments/yuno-3DS-netcetera-iOS/releases/download/1.1.0/Yuno3DSNetcetera.xcframework.zip",
            checksum: "9ae559e1e7d491b47cc66d82aeac85f9f6a3873e77f3be1ef18288d3da10f37b"
        ),
        .binaryTarget(
            name: "ThreeDS_SDK",
            url: "https://nexus.extranet.netcetera.biz/nexus/repository/public-repository-maven/com/netcetera/nca-341-2/3ds-sdk/ios/release/2.6.01/ThreeDS_SDK.zip",
            checksum: "90284f80dbad0258687d39a724d967f53d47db99cf4bfc3faaeee1fbe9671e2a"
        )
    ]
)
