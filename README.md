# Yuno 3DS Netcetera iOS

Netcetera 3DS provider for the [Yuno iOS SDK](https://github.com/yuno-payments/yuno-sdk-ios).

## Requirements

- iOS 14+
- [YunoSDK](https://github.com/yuno-payments/yuno-sdk-ios) installed in your app.

## Installation (Swift Package Manager)

In Xcode: **File → Add Package Dependencies…** and use the URL:

```
https://github.com/yuno-payments/yuno-3DS-netcetera-iOS
```

Add the `Yuno3DSNetcetera` library to your app target.

## Integration

```swift
import YunoSDK
import Yuno3DSNetcetera
```

The provider auto-registers with `YunoThreeDSRegistry` at framework load time —
no extra configuration required.

## Sandbox certificates

When testing in sandbox, add the Visa test root certificate
`acq-root-certeq-prev-environment.crt` to your app's bundle (Resources). The
Netcetera 3DS SDK looks it up by name in the main bundle.

## Releases

Each release ships a prebuilt `Yuno3DSNetcetera.xcframework.zip` referenced from
`Package.swift`. The `ThreeDS_SDK.xcframework` from Netcetera is fetched
automatically as a binary dependency.
