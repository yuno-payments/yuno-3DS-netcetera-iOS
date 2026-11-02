# AGENTS.md — yuno-3DS-netcetera-iOS

Instructions for any engineer or coding agent working in this repository.
`CLAUDE.md` imports this file; keep this the single source of truth.

## What this repository is

The distribution manifests for **`Yuno3DSNetcetera`**, an optional 3-D Secure
(3DS) provider for the [Yuno iOS SDK](https://github.com/yuno-payments/yuno-sdk-ios)
(`YunoSDK`). It plugs Netcetera's EMVCo 3DS SDK (`ThreeDS_SDK`) into the
`YunoThreeDSRegistry` hook that `YunoSDK` exposes from `2.17.0` (enrollment
3DS needs `YunoSDK` `2.22.0`+). Consumers are merchant iOS apps that already
use `YunoSDK` and need in-app 3DS challenges.

No Swift source of the provider lives here. The repository only publishes
pre-built binaries through two package managers:

| File | Role |
|------|------|
| `Package.swift` | SwiftPM manifest (tools 5.7, iOS 14). Library product `Yuno3DSNetcetera` → wrapper target `Yuno3DSNetceteraWrapper`, which depends on two **remote** binary targets: `Yuno3DSNetcetera` (GitHub Release asset of this repo) and `ThreeDS_SDK` (Netcetera Nexus). Each is pinned by URL and SHA-256 `checksum`. |
| `Yuno3DSNetcetera.podspec` | CocoaPods spec. `s.version` drives `s.source` (`…/releases/download/<version>/YunoSDK3DSNetcetera.zip`), which must contain `Yuno3DSNetcetera.xcframework` and `ThreeDS_SDK.xcframework` (`vendored_frameworks`). Static framework, iOS 14, Swift 5.7, links `UIKit` and `Combine`, `BUILD_LIBRARY_FOR_DISTRIBUTION = YES`. |
| `Yuno3DSNetceteraWrapper/dummy.m`, `include/dummy.h` | Empty Objective-C `Dummy` class. SwiftPM requires one source file per target; the wrapper exists so one product can link both binaries and carry `linkerSettings` (FirebaseAnalyticsWrapper pattern). Do not add logic here. |
| `README.md` | Merchant-facing integration guide (requirements, SPM/CocoaPods install, `register()` usage, sandbox certificate, troubleshooting). |
| `.gitignore` | Ignores `*.xcframework`, `*.xcframework.zip`, `build/`, `Package.resolved`. Binaries are never committed. |

There are no tests, no CI workflows (`.github/` does not exist), no lint
configuration and no build scripts in this repository.

### Current versions (read from the files, update this table on every bump)

| Component | Version | Where |
|-----------|---------|-------|
| `Yuno3DSNetcetera` (this package) | `1.1.0` | `Yuno3DSNetcetera.podspec` `s.version`; `Package.swift` release URL `…/download/1.1.0/…` |
| Netcetera `ThreeDS_SDK` | `2.6.01` | `Package.swift` Nexus URL `…/ios/release/2.6.01/ThreeDS_SDK.zip` |
| Minimum `YunoSDK` | `2.17.0` (`2.22.0` for enrollment 3DS) | `README.md` |

This package has its own version line, independent of `YunoSDK` (release
`1.1.0` replaced an earlier `2.17.0` tag, commit `8e468e1`).

### Runtime behaviour consumers depend on

- SwiftPM: the binary auto-registers with `YunoThreeDSRegistry` through an
  Objective-C `+load` bootstrap; `import Yuno3DSNetcetera` is enough.
- CocoaPods: static framework, no `+load`; the app must call
  `Yuno3DSNetcetera.register()` once before `Yuno.initialize(...)`.
- Sandbox needs the Visa test root `acq-root-certeq-prev-environment.crt` in
  the merchant app bundle, obtained from the Yuno TAM.

## What must not change

1. **Never modify, re-sign, patch, re-zip or commit a binary.** Neither
   `Yuno3DSNetcetera.xcframework` nor `ThreeDS_SDK.xcframework` (nor their zips)
   belong in git; `.gitignore` enforces this and must keep doing so. A binary
   only changes by publishing a new release asset and repointing the manifests.
2. **Never edit a published release asset in place.** SwiftPM verifies
   `checksum`, and every merchant on that version breaks if the bytes change.
   Ship a new version instead.
3. **Never change a `checksum` without the matching URL/asset**, and never
   change one without computing it from the exact published zip.
4. **`ThreeDS_SDK` is proprietary to Netcetera AG** under its own commercial
   licence (see `README.md` → License). Only the Yuno-authored files are MIT
   (`Yuno3DSNetcetera.podspec` licence text). Do not redistribute
   `ThreeDS_SDK` from any other host, vendor its contents, decompile it or
   copy its headers into this repo. Any further licence or NDA terms are not
   recorded in this repository; ask the repository owner before changing how
   it is distributed.
5. **Never commit certificates or credentials.** The sandbox
   `acq-root-certeq-prev-environment.crt` is not distributed publicly
   (`README.md`); `.gitignore` does not exclude `*.crt`, so check `git status`
   before committing.
6. Keep the public names stable: product/module/pod `Yuno3DSNetcetera`,
   target `Yuno3DSNetceteraWrapper`, binary target `ThreeDS_SDK`,
   `Yuno3DSNetcetera.register()`. Renaming any of them breaks merchants.
7. Keep iOS 14 / Swift 5.7 minimums, `static_framework = true` and
   `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` unless the release explicitly
   changes them and `README.md` says so.

## How to bump versions

The `Yuno3DSNetcetera.xcframework` is built outside this repository (its source
is not here). A bump in this repo is manifest-only: the asset is published
first, then the manifests are pointed at it.

### New `Yuno3DSNetcetera` release (e.g. `1.1.0` → `1.2.0`)

1. Obtain the new `Yuno3DSNetcetera.xcframework`, built with
   `BUILD_LIBRARY_FOR_DISTRIBUTION = YES` against the matching
   `ThreeDS_SDK`.
2. Produce two zips:
   - `Yuno3DSNetcetera.xcframework.zip` (SwiftPM; just the xcframework).
   - `YunoSDK3DSNetcetera.zip` (CocoaPods; `Yuno3DSNetcetera.xcframework`
     **and** `ThreeDS_SDK.xcframework` at the zip root, matching
     `vendored_frameworks`).
3. Create a GitHub Release whose **tag equals the new version** (`1.2.0`) and
   attach both zips under exactly those names.
4. Compute the SwiftPM checksum of the uploaded SwiftPM zip:
   `swift package compute-checksum Yuno3DSNetcetera.xcframework.zip`
   (equivalent to `shasum -a 256`).
5. Edit `Package.swift`: the `Yuno3DSNetcetera` binary target `url`
   (`…/releases/download/1.2.0/Yuno3DSNetcetera.xcframework.zip`) and
   `checksum`.
6. Edit `Yuno3DSNetcetera.podspec`: `s.version = '1.2.0'` (`s.source` follows).
7. Update `README.md` (install snippets `>= 1.2.0` / `~> 1.2.0`, minimum
   `YunoSDK` if it changed) and the version table in this file.
8. Commit as `chore(release): <version> — <summary>` (prior release: `8e468e1`).

### New Netcetera `ThreeDS_SDK` version (e.g. `2.6.01` → `2.x.yy`)

1. Confirm the release exists on Netcetera's Nexus under
   `…/com/netcetera/nca-341-2/3ds-sdk/ios/release/<version>/ThreeDS_SDK.zip`.
2. Download it and compute its checksum with
   `swift package compute-checksum ThreeDS_SDK.zip`.
3. Edit the `ThreeDS_SDK` binary target `url` and `checksum` in `Package.swift`.
4. Rebuild `Yuno3DSNetcetera.xcframework` against the new `ThreeDS_SDK` and
   ship it as a new `Yuno3DSNetcetera` release (section above): the CocoaPods
   zip bundles `ThreeDS_SDK.xcframework`, so a Netcetera bump always needs a
   new `YunoSDK3DSNetcetera.zip`, and therefore a new pod version.
5. If the Netcetera SDK adds system-framework requirements, declare them in
   `s.frameworks` (podspec) and, for SwiftPM, as `linkerSettings` on
   `Yuno3DSNetceteraWrapper`.

## How to validate

None of these run in CI here and none can run in a Linux container; run them
on a Mac with Xcode 26.2+ and CocoaPods installed. **These commands are still
to be validated by a developer** on the next release; correct this section if
they need different flags.

- Podspec, against the published release asset:
  `pod spec lint Yuno3DSNetcetera.podspec`
- Podspec, locally (requires both `.xcframework` folders unzipped at the
  repo root, where `vendored_frameworks` expects them; they stay gitignored):
  `pod lib lint Yuno3DSNetcetera.podspec`
- SwiftPM manifest and checksums (downloads both binary targets and fails on a
  checksum mismatch): `swift package resolve`, then
  `xcodebuild -scheme Yuno3DSNetcetera -destination 'generic/platform=iOS' build`.
- Smoke test in a sample app with `YunoSDK` ≥ `2.17.0`: SwiftPM build runs a
  3DS challenge without calling `register()`; CocoaPods build runs it after
  `Yuno3DSNetcetera.register()`. Use the sandbox certificate from the TAM.
- Re-read `README.md` so its versions match the manifests.

## Architecture direction

ADR-0004 ("Distribute iOS SDK external modules from the public SDK
repository", `yuno-payments/architecture-decision-records` @ `f47b352`)
decides that optional iOS modules such as this one become products of the
`yuno-sdk-ios` package. Check with the iOS SDK team before investing in
standalone release tooling here; until the move happens this repository is
still what merchants consume.

## Working rules for agents and PRs

- Scope every PR to one concern. Documentation, a version bump and a manifest
  change are separate PRs unless they are one release.
- A refactor that would touch more than 3 files beyond the task's own files
  goes in a separate PR with its own AnyForge work item.
- Reference the work item in the PR body (`Fixes <item code>`).
- Do not add CI, scripts, dependencies or new targets without a work item;
  any new third-party dependency must be pinned (URL + checksum, or exact pod
  version) and noted in the PR for the dependency register.
- English for code, comments, commits and PRs. No secrets or certificates in
  the repo.
