# TTcare Flutter SDK Sample

🌐 **English** · [한국어](README.ko.md) · [日本語](README.ja.md)

This sample shows how a Flutter app can launch TTcare native scan SDK flows through a `MethodChannel`, then display the returned SDK result JSON in Flutter.

The README is written so Flutter integrators can understand the Android native SDK bridge without opening the Android sample README separately.

## Native SDK Versions

| Platform | Native SDK |
| --- | --- |
| Android | `io.github.aiforpet-ttcare:scansdk-lib:2.1.0` |
| iOS | `AIScan 2.0.3` |

Android requires Android 9.0+ (`minSdk 28`). Android SDK 2.1.0 supports result screen localization for English, Korean, Japanese, Italian, Swedish, and Thai.

## What This Sample Provides

- Flutter UI for selecting pet type and scan part
- Flutter toggles for native SDK options
- Android native bridge that launches TTcare SDK activities
- iOS native bridge setup point for `AIScan`
- JSON result overlay in Flutter
- Android ProGuard/R8 rules for release builds

## Screen Flow

- Top of screen: SDK option toggles
  - `enableQuestionnaire`
  - `enableResultView`
  - `enablePdfShare`
- Body: pet and scan-part cards
  - DOG: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH`
  - CAT: `EYE`, `TEETH`
- Tapping a card calls `launchSdk` over the native channel.
- The native layer launches the matching SDK camera activity.
- The SDK result is returned to Flutter and displayed as formatted JSON.

## MethodChannel Contract

| Field | Value |
| --- | --- |
| Channel | `com.aiforpet.sdk/channel` |
| Method | `launchSdk` |

### Flutter Arguments

```json
{
  "petType": "DOG | CAT",
  "partType": "EYE | EAR | BODY | FOOT | TEETH",
  "enablesQuestionnaire": true,
  "enableResultView": true,
  "enablePdfShare": true,
  "authConfig": "{ TTcare auth JSON string }"
}
```

### Argument Details

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `petType` | String | Yes | `DOG` or `CAT` |
| `partType` | String | Yes | Flutter sample value: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH` |
| `authConfig` | String | Yes | TTcare authentication JSON string loaded from `assets/auth-config.json` |
| `enablesQuestionnaire` | Boolean | No | Controls SDK questionnaire usage. Default in this sample: `true` |
| `enableResultView` | Boolean | No | Controls whether the SDK built-in result screen is shown. Default in this sample: `true` |
| `enablePdfShare` | Boolean | No | Controls whether the built-in result screen shows the PDF share button. Default in this sample: `true` |

### Part Mapping on Android

The Android bridge maps Flutter `partType` values to native SDK activities.

| Flutter `partType` | Android SDK Activity | Native SDK extra |
| --- | --- | --- |
| `EYE` | `EyeCameraActivity` | none |
| `TEETH` | `ToothCameraActivity` | none |
| `EAR` | `SkinCameraActivity` | `partType=EAR` |
| `BODY` | `SkinCameraActivity` | `partType=BELLY` |
| `FOOT` | `SkinCameraActivity` | `partType=FOOT` |

For skin scans, the native Android SDK requires one of `EAR`, `BELLY`, or `FOOT`. The Flutter sample uses `BODY` in the UI and maps it to Android `BELLY`.

## Android Native SDK Bundle Contract

If you extend `android/app/src/main/kotlin/.../MainActivity.kt`, use the following Bundle contract when launching the Android native SDK directly.

### Required Fields

| Name | Type | Description |
| --- | --- | --- |
| `petType` | String | `DOG` or `CAT` |
| `userId` | String | User identifier from your service |
| `ttConf` | String | TTcare authentication JSON string |

### Required for Skin Scans

| Name | Type | Description |
| --- | --- | --- |
| `partType` | String | Required for `SkinCameraActivity`. One of `EAR`, `BELLY`, `FOOT` |

### Optional Fields

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `petId` | String | none | Pet identifier from your service |
| `petBirthday` | String | none | Pet birthday. `yyyy-MM-dd` recommended |
| `petBreedName` | String | none | Breed name |
| `petGender` | String | none | `M`, `F`, `MC`, `FC` |
| `petAdditionalInfo` | String | none | Additional metadata. JSON string recommended |
| `guideUrl` | String | none | SDK guide web view URL |
| `isFlashMode` | Boolean | `false` | Whether flash starts enabled |
| `enablesQuestionnaire` | Boolean | `true` | Whether to use the SDK questionnaire |
| `enableResultView` | Boolean | `true` | Whether to show the SDK built-in result screen |
| `enablePdfShare` | Boolean | `false` | Whether to show the PDF share button on the SDK result screen |

## Android Native Bridge Example

The sample Android bridge creates a Bundle like this:

```kotlin
val bundle = Bundle().apply {
    putString("petType", petType)
    putString("userId", "userId")
    putString("petId", "petId")
    putString("petBirthday", "2025-01-01")
    putString("petBreedName", "petBreedName")
    putString("petGender", "M")
    putBoolean("enablesQuestionnaire", enablesQuestionnaire)
    putBoolean("enableResultView", enableResultView)
    putBoolean("enablePdfShare", enablePdfShare)
    putString("petAdditionalInfo", petAdditionalInfo.toString())
    putString("ttConf", authConfig)
    putString("guideUrl", guideUrl)

    if (partType == "EAR" || partType == "BODY" || partType == "FOOT") {
        val nativePartType = if (partType == "BODY") "BELLY" else partType
        putString("partType", nativePartType)
    }
}
```

Replace the sample values such as `userId`, `petId`, `petBirthday`, and `petBreedName` with values from your service when integrating into a production app.

## Option Behavior

### `enablesQuestionnaire`

- `true`: SDK questionnaire is used, and questionnaire answers can affect the final status.
- `false`: SDK proceeds without the questionnaire.

### `enableResultView`

- `true`: SDK built-in result screen is shown. The result returns to Flutter after the SDK result screen is closed.
- `false`: SDK does not show the built-in result screen and returns the result through the native result flow.

### `enablePdfShare`

- `true`: SDK result screen shows a PDF share button.
- `false`: PDF share button is hidden.

`enablePdfShare` is meaningful when `enableResultView=true`.

## Return Value

The channel returns:

```dart
String?
```

If the returned value is JSON, the sample pretty-prints it with 4-space indentation and shows it in a Flutter overlay.

## Result JSON Overview

The SDK result JSON can include:

| Field | Description |
| --- | --- |
| `status` | SDK processing status, usually `SUCCESS` |
| `petType` | `DOG` or `CAT` |
| `part` | Scan part, such as `EYE`, `SKIN`, `TOOTH` |
| `createdAt` | Analysis creation time |
| `subPart` | Detailed position such as `EYER`, `EYEL`, `EAR`, `BELLY`, `FOOT`, `TCENTER` |
| `userId` | User ID passed by the host app |
| `questions` | Questionnaire answers when questionnaire is enabled |
| `metadata` | Pet metadata passed by the host app |
| `response` | User-facing result summary |

`response.status` is one of:

| Status | Meaning |
| --- | --- |
| `NORMAL` | No abnormal signs detected |
| `CAUTION` | Observation is recommended |
| `WARNING` | Follow-up is recommended |

Detected symptoms may include local file paths:

| Field | Description |
| --- | --- |
| `heatmapPath` | Local heatmap image path, `file://...` |
| `cropImageUrl` | Local crop image path, `file://...` |

These are local files inside the app sandbox, not remote URLs. If your app needs to keep or upload these images, copy or upload them before clearing SDK-generated files.

## SDK Auth Configuration

Copy `assets/auth-config.json.example` to `assets/auth-config.json` and fill in the credentials issued for your project.

```bash
cp assets/auth-config.json.example assets/auth-config.json
```

`assets/auth-config.json` is ignored by Git because it contains secrets. Do not commit real credentials.

For production apps, load the TTcare authentication JSON according to your security policy instead of keeping it as plain text in assets.

## iOS Setup

Open `ios/Runner.xcworkspace` in Xcode and select your Apple Development Team under the Runner target's **Signing & Capabilities**.

The iOS sample uses `AIScan 2.0.3`.

## Android ProGuard / R8

Release builds with R8 minification require keep rules for JNI-referenced classes. The sample already includes these rules in `android/app/proguard-rules.pro` and wires them into the release build type.

## Run

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
```
