# fluttersdksample

🌐 **English** · [한국어](README.ko.md) · [日本語](README.ja.md)

A Flutter demo app that invokes the aiforpet diagnosis SDK.
The host native (Android / iOS) layer exposes a `MethodChannel`; the Flutter UI calls the SDK entry point through it and renders the JSON result.

Native SDK versions: Android `scansdk-lib:2.1.0`, iOS `AIScan 2.0.3`.
Android SDK 2.1.0 supports result screen localization for English, Korean, Japanese, Italian, Swedish, and Thai.
Android requires Android 9.0+ (`minSdk 28`).

## Overview

- Top of screen: three SDK option toggles (`enableQuestionnaire`, `enableResultView`, `enablePdfShare`)
- Body: per-pet diagnosis cards
  - DOG: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH`
  - CAT: `EYE`, `TEETH`
- Tapping a card invokes `launchSdk` over the native channel; the result is shown in a JSON-formatted overlay.

## MethodChannel spec

| Field | Value |
| --- | --- |
| Channel | `com.aiforpet.sdk/channel` |
| Method | `launchSdk` |

### Arguments

```json
{
  "petType": "DOG | CAT",
  "partType": "EYE | EAR | BODY | FOOT | TEETH",
  "enablesQuestionnaire": true,
  "enableResultView": true,
  "enablePdfShare": true
}
```

`enablePdfShare` is an Android SDK 2.1.0 option that controls whether the built-in result screen shows the PDF share button.

### Return value

`String?` — SDK result. If JSON, it is pretty-printed with 4-space indentation; otherwise rendered as raw text.

## Setup

### 1. SDK auth configuration

Copy `assets/auth-config.json.example` to `assets/auth-config.json` and fill in the credentials issued for your project.

```bash
cp assets/auth-config.json.example assets/auth-config.json
# Edit clientId / clientKeyId / clientKeySecret / clientKey
```

> ⚠️ `assets/auth-config.json` is listed in `.gitignore`. It contains a secret key — **never commit it**.

### 2. iOS signing

Open `ios/Runner.xcworkspace` in Xcode and select your Apple Development Team under the Runner target's **Signing & Capabilities** (Automatic signing).

### 3. Android ProGuard rules (release builds)

Release builds with R8 minification require keep rules for JNI-referenced classes (ONNX Runtime, LiteRT, AIScan SDK). These are already provided in `android/app/proguard-rules.pro` and wired into the release build type. No further action needed for this sample.

## Run

```bash
flutter pub get
flutter run                 # debug
flutter run --release       # release (verifies ProGuard rules)
```

The host native layer must implement the channel above for the SDK calls to succeed.

## Verify

```bash
flutter analyze
flutter test
```
