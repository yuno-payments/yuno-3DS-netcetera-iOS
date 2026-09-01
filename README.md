# Yuno 3DS Netcetera iOS

Netcetera-powered 3-D Secure (3DS) provider for the [Yuno iOS SDK](https://github.com/yuno-payments/yuno-sdk-ios).

This package ships an optional 3DS authentication layer built on top of
[Netcetera's 3DS SDK](https://3dsdk.netcetera.com/). Install it alongside
`YunoSDK` only when your integration needs to perform in-app 3DS challenges.
If you are not enabling 3DS, you do not need this package.

## Requirements

- **iOS 14+**
- **Xcode 26.2+**
- **Swift 5.7+**
- **[YunoSDK](https://github.com/yuno-payments/yuno-sdk-ios) `2.17.0` or higher**
  installed in the same app target. Earlier versions of YunoSDK do not expose
  the `YunoThreeDSRegistry` hook that this package plugs into and will fail to
  link. 3DS in the enrollment flow requires YunoSDK `2.22.0` or higher.

## Installation

### Swift Package Manager (recommended)

In Xcode: **File → Add Package Dependencies…** and use the URL:

```
https://github.com/yuno-payments/yuno-3DS-netcetera-iOS
```

Select the `Yuno3DSNetcetera` library and add it to your app target.

You also need `YunoSDK` itself, added as a separate Swift Package:

```
https://github.com/yuno-payments/yuno-sdk-ios
```

`Yuno3DSNetcetera` resolves to **>= 1.1.0**, and `YunoSDK` to **>= 2.17.0**
(**>= 2.22.0** for enrollment 3DS), so the two stay ABI-compatible.

### CocoaPods

```ruby
platform :ios, '14.0'

target 'YourApp' do
  use_frameworks!

  pod 'YunoSDK',          '~> 2.17'
  pod 'Yuno3DSNetcetera', '~> 1.1.0'
end
```

Then:

```bash
pod install
```

## Usage

### With Swift Package Manager

The provider auto-registers with `YunoThreeDSRegistry` at framework load
time via an Objective-C `+load` bootstrap. No explicit setup is required:

```swift
import YunoSDK
import Yuno3DSNetcetera

// Initialize YunoSDK as usual — 3DS is already wired up.
Yuno.initialize(apiKey: "YOUR_API_KEY", config: YunoConfig())
```

### With CocoaPods

The CocoaPods variant is shipped as a **static** framework, so the
auto-register bootstrap is not included. Register the provider manually
**once**, before any payment or enrollment flow:

```swift
import YunoSDK
import Yuno3DSNetcetera

@main
struct YourApp: App {
    init() {
        Yuno3DSNetcetera.register()
        Yuno.initialize(apiKey: "YOUR_API_KEY", config: YunoConfig())
    }

    var body: some Scene { /* ... */ }
}
```

Once registered, the YunoSDK will route any 3DS challenges through the
Netcetera provider automatically — no further changes to your payment or
enrollment code are needed.

## Sandbox / staging certificates

When testing against the YunoSDK sandbox environment, the Netcetera 3DS
SDK requires a Visa test root certificate
(`acq-root-certeq-prev-environment.crt`) to be present in your app's
main bundle.

**Contact your Yuno TAM (Technical Account Manager) to obtain the
certificate file.** It is not distributed publicly.

Once you have it:

1. Drag the `.crt` into Xcode's Project Navigator inside your app target's
   group.
2. Check **Copy items if needed** and tick your app target under
   **Add to targets**.
3. Confirm it appears under **Target → Build Phases → Copy Bundle
   Resources**.

Netcetera looks the certificate up by **filename** in the main bundle,
so the path inside the project doesn't matter as long as the file ends
up in the final `.app`. In production environments this file is not
used and can be omitted from Release builds.


## Troubleshooting

**Linker error referencing `YunoThreeDSRegistry`**: your `YunoSDK`
version is older than `2.17.0`. Bump it.

**3DS challenge UI never appears (CocoaPods)**: confirm you are calling
`Yuno3DSNetcetera.register()` before `Yuno.initialize(...)`. SPM users
do not need this call.

**`acq-root-certeq-prev-environment.crt not found` in console**: only
relevant when testing in sandbox. Add the certificate to your app bundle
as described above. Safe to ignore in production builds.

## License

MIT — see headers in [Yuno3DSNetcetera.podspec](Yuno3DSNetcetera.podspec).
The bundled `ThreeDS_SDK.xcframework` is property of Netcetera AG and
subject to its own commercial license terms.
