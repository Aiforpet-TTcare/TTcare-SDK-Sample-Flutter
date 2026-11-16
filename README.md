# TTcare Flutter SDK Sample

🌐 **English** · [한국어](README.ko.md) · [日本語](README.ja.md)

This sample shows how a Flutter app can launch TTcare native scan SDK flows through a `MethodChannel`, then display the returned SDK result JSON in Flutter.

The README is written so Flutter integrators can understand the Android native SDK bridge without opening the Android sample README separately.

## Native SDK Versions

| Platform | Native SDK |
| --- | --- |
| Android | `io.github.aiforpet-ttcare:scansdk-lib:3.2.0` |
| iOS | `AIScan 2.0.3` |

Android SDK 3.2.0 supports API 23+, while this Flutter sample currently sets `minSdk 28`. The SDK prepares images on-device and obtains final analysis from the server. Camera preview appears during preparation, but capture stays disabled until ready. An invalid SDK key cancels the SDK activity; pass the issued key unchanged. The Android result Bundle and public JSON keys are unchanged from 3.1.0.

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
  - `enableMultiMode` (Android only)
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
  "enableMultiMode": false,
  "sdkKey": "Enter your issued SDK key",
  "petName": "Coco"
}
```

### Argument Details

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `petType` | String | Yes | `DOG` or `CAT` |
| `partType` | String | Yes | Flutter sample value: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH` |
| `sdkKey` | String | Yes | SDK key issued for your project |
| `petName` | String | No | Pet name forwarded to the Android SDK for the built-in result screen and PDF report text |
| `enablesQuestionnaire` | Boolean | No | Controls SDK questionnaire usage. Default in this sample: `true` |
| `enableResultView` | Boolean | No | Controls whether the SDK built-in result screen is shown. Default in this sample: `true` |
| `enablePdfShare` | Boolean | No | Controls whether the built-in result screen shows the PDF share button. Default in this sample: `true` |
| `enableMultiMode` | Boolean | No | Android only: collect up to four photos; default `false` |

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
| `sdkKey` | String | SDK key issued for your project |

### Required for Skin Scans

| Name | Type | Description |
| --- | --- | --- |
| `partType` | String | Required for `SkinCameraActivity`. One of `EAR`, `BELLY`, `FOOT` |

### Optional Fields

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `petId` | String | none | Pet identifier from your service |
| `petName` | String | none | Pet name used in the built-in result screen and PDF report text |
| `petBirthday` | String | none | Pet birthday. `yyyy-MM-dd` recommended |
| `petBreedName` | String | none | Breed name |
| `petGender` | String | none | `M`, `F`, `MC`, `FC` |
| `guideUrl` | String | SDK default | Optional override for the SDK guide URL. This sample omits it |
| `isFlashMode` | Boolean | `false` | Whether flash starts enabled |
| `enablesQuestionnaire` | Boolean | `true` | Whether to use the SDK questionnaire |
| `enableResultView` | Boolean | `true` | Whether to show the SDK built-in result screen |
| `enablePdfShare` | Boolean | SDK: `false`; sample: `true` | Whether to show the PDF share button on the SDK result screen |
| `enableMultiMode` | Boolean | `false` | Android server analysis: collect up to four photos and return a JSON array |

Without a `guideUrl` override, Android SDK 3.2.0 uses `https://guide.ai4pet.com/sdk/guide/{locale}/{pet}/{part}` with its own locale and scan-part mapping.

## Android Native Bridge Example

The sample Android bridge creates a Bundle like this:

```kotlin
val bundle = Bundle().apply {
    putString("petType", petType)
    putString("userId", "userId")
    putString("petId", "petId")
    putString("petName", petName)
    putString("petBirthday", "2025-01-01")
    putString("petBreedName", "petBreedName")
    putString("petGender", "M")
    putBoolean("enablesQuestionnaire", enablesQuestionnaire)
    putBoolean("enableResultView", enableResultView)
    putBoolean("enablePdfShare", enablePdfShare)
    putBoolean("enableMultiMode", enableMultiMode)
    putString("sdkKey", sdkKey)

    if (partType == "EAR" || partType == "BODY" || partType == "FOOT") {
        val nativePartType = if (partType == "BODY") "BELLY" else partType
        putString("partType", nativePartType)
    }
}
```

Replace the sample values such as `userId`, `petId`, `petBirthday`, and `petBreedName` with values from your service when integrating into a production app.

## Option Behavior

### `enablesQuestionnaire`

- `true`: SDK questionnaire is used; follow the final status returned by the server.
- `false`: SDK proceeds without the questionnaire.

### `enableResultView`

- `true`: SDK built-in result screen is shown. The result returns to Flutter after the SDK result screen is closed.
- `false`: SDK does not show the built-in result screen and returns the result through the native result flow.

### `enablePdfShare`

- `true`: SDK result screen shows a PDF share button.
- `false`: PDF share button is hidden.

`enablePdfShare` is meaningful when `enableResultView=true`.

### `enableMultiMode` (Android only)

- `false` (default): a single scan returns one JSON object.
- `true`: up to four photos can be analyzed. The JSON string contains an array in capture order, even when only one photo is submitted. Check each item's status separately.

## Return Value

The channel returns:

```dart
String?
```

The channel returns the native JSON string unchanged. The sample pretty-prints either an object or an array and shows it in a Flutter overlay.

## Result JSON Overview

The SDK result JSON can include:

| Field | Description |
| --- | --- |
| `status` | SDK processing status, usually `SUCCESS` |
| `petType` | `DOG` or `CAT` |
| `part` | Scan part, such as `EYE`, `SKIN`, `TOOTH` |
| `createdAt` | Analysis creation time |
| `questions` | Questionnaire answers when questionnaire is enabled |
| `response` | User-facing result summary |
| `userId` | User identifier passed through the Android bridge |
| `petId` | Pet identifier passed through the Android bridge, when provided |
| `subPart` | Detailed position code, such as `EYEL`, `EAR`, or `TCENTER`, when available |

The public result JSON no longer includes a `metadata` object. Internal model fields such as `score`, `predValues`, `pred_values`, and `modelName` are not returned to Flutter.

`response.status` is one of:

| Status | Meaning |
| --- | --- |
| `NORMAL` | No abnormal signs detected |
| `CAUTION` | Observation is recommended |
| `WARNING` | Follow-up is recommended |

Use the final status returned by the server. Do not recalculate or override it from questionnaire answers.

### Detailed Result Blocks

`questions` contains questionnaire answers when the questionnaire flow is enabled.

| Field | Description |
| --- | --- |
| `text` | Questionnaire question text |
| `select` | User answer, `Y` or `N` |

`response.description` is result-level guidance for UI rendering.

| Field | Description |
| --- | --- |
| `title` | Guidance title |
| `contents` | List of guidance body lines |

Detected symptoms include model output and image URLs:

| Field | Description |
| --- | --- |
| `abnormLevel` | Abnormality level calculated by the SDK |
| `cropImageUrl` | HTTPS URL for the crop image |
| `heatmapUrl` | HTTPS URL for the heatmap image |
| `isAbnormal` | Whether the symptom is judged abnormal |
| `resultLabel` | Result label, such as `normal` or `abnormal` |
| `details` | Symptom explanation blocks |

`response.symptoms[].details` uses the following keys.

| Key | Description |
| --- | --- |
| `what_it_is` | General explanation of the detected sign |
| `related_clinical_conditions` | Partner-facing related clinical conditions and factors |
| `possible_causes` | Guardian-friendly possible causes |
| `what_you_can_do` | Home-care guidance and observation tips |

### Position Codes

| Code | Scan type | Description |
| --- | --- | --- |
| `EYER` | Eye | Right eye |
| `EYEL` | Eye | Left eye |
| `EAR` | Skin | Ear |
| `BELLY` | Skin | Belly |
| `FOOT` | Skin | Paw |
| `TCENTER` | Teeth | Front teeth |
| `TRIGHT` | Teeth | Right teeth |
| `TLEFT` | Teeth | Left teeth |

Result images are remote URLs. To display a returned image in Flutter, load the returned URL directly.

```dart
Image.network(heatmapUrl);
```

### Sample Result JSON

```json
{
  "status": "SUCCESS",
  "petType": "DOG",
  "part": "EYE",
  "createdAt": 1781485248231,
  "userId": "userId",
  "petId": "petId",
  "subPart": "EYEL",
  "questions": [
    { "text": "Are the pupil sizes different?", "select": "N" }
  ],
  "response": {
    "status": "WARNING",
    "title": "A veterinary visit is recommended as soon as possible.",
    "analyzedDate": "2026. 06. 15 10:00",
    "description": {
      "title": "When to visit a veterinary clinic",
      "contents": [
        "If squinting or blinking does not improve",
        "If redness, swelling, or discharge continues or worsens"
      ]
    },
    "symptoms": [
      {
        "code": "opacity",
        "abnormLevel": 1,
        "cropImageUrl": "https://cdn-results.ai4pet.com/.../diagnosis_crop",
        "name": "Opacity",
        "isAbnormal": true,
        "resultLabel": "abnormal",
        "heatmapUrl": "https://cdn-results.ai4pet.com/.../diagnosis_heatmap",
        "details": [
          {
            "key": "what_it_is",
            "title": "What is this sign?",
            "contents": ["The eye surface appears cloudy or blurred."]
          }
        ]
      }
    ]
  }
}
```

## SDK Key Configuration

The Flutter sample sends the Android SDK key through the `launchSdk` MethodChannel call.

```dart
const String _kSdkKey = 'Enter your issued SDK key';
```

Replace the placeholder with the SDK key issued for your project before running the Android sample flow. Do not commit real production SDK keys to public source code; load them according to your security policy.

## iOS Setup

Open `ios/Runner.xcworkspace` in Xcode and select your Apple Development Team under the Runner target's **Signing & Capabilities**.

The iOS sample uses `AIScan 2.0.3`.

## Android ProGuard / R8

The SDK ships consumer R8 rules. The sample also includes host-app rules in `android/app/proguard-rules.pro`; verify a release build before shipping.

## Run

Build the Android sample with JDK 17. This project uses Gradle 8.14, AGP 8.11.1, and Kotlin 2.2.20. If Flutter selects a newer Android Studio JDK, check `flutter doctor -v` and configure a JDK 17 path with `flutter config --jdk-dir=<JDK_17_PATH>`.

```bash
flutter pub get
flutter run
```

## Verify

```bash
flutter analyze
flutter test
```
