# TTcare Flutter SDK Sample

🌐 [English](README.md) · **한국어** · [日本語](README.ja.md)

이 샘플은 Flutter 앱에서 `MethodChannel`을 통해 TTcare 네이티브 Scan SDK를 실행하고, SDK가 반환한 결과 JSON을 Flutter 화면에 표시하는 예제입니다.

이 README는 Flutter 연동자가 Android 샘플 README를 따로 열지 않아도 Android 네이티브 SDK 브릿지 구조와 파라미터를 이해할 수 있도록 작성되었습니다.

## 네이티브 SDK 버전

| 플랫폼 | 네이티브 SDK |
| --- | --- |
| Android | `io.github.aiforpet-ttcare:scansdk-lib:2.2.3` |
| iOS | `AIScan 2.0.3` |

Android는 Android 9.0 이상(`minSdk 28`)이 필요합니다. Android SDK 2.2.3에서는 기존 단건 계약을 기본값으로 유지하면서 선택형 TTAPI 멀티 촬영을 추가했습니다.

## 이 샘플이 제공하는 것

- 펫 종류와 검사 부위를 선택하는 Flutter UI
- 네이티브 SDK 옵션 토글
- TTcare Android SDK Activity를 실행하는 Android 네이티브 브릿지
- iOS `AIScan` 연동 시작점
- Flutter JSON 결과 오버레이
- Android release 빌드를 위한 ProGuard/R8 규칙

## 화면 흐름

- 화면 상단: SDK 옵션 토글
  - `enableQuestionnaire`
  - `enableResultView`
  - `enablePdfShare`
  - `enableMultiMode` (Android TTAPI 전용)
- 화면 본문: 펫 종류와 검사 부위 카드
  - DOG: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH`
  - CAT: `EYE`, `TEETH`
- 카드를 누르면 네이티브 채널로 `launchSdk`를 호출합니다.
- 네이티브 레이어가 검사 부위에 맞는 SDK 카메라 Activity를 실행합니다.
- SDK 결과가 Flutter로 반환되고 JSON 형태로 표시됩니다.

## MethodChannel 계약

| 항목 | 값 |
| --- | --- |
| 채널 | `com.aiforpet.sdk/channel` |
| 메서드 | `launchSdk` |

### Flutter 인자

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

### 인자 설명

| 이름 | 타입 | 필수 | 설명 |
| --- | --- | --- | --- |
| `petType` | String | 예 | `DOG` 또는 `CAT` |
| `partType` | String | 예 | Flutter 샘플 값: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH` |
| `sdkKey` | String | 예 | 프로젝트용으로 발급받은 SDK key |
| `petName` | String | 아니오 | Android SDK 내장 결과 화면 및 PDF 리포트 문구에 전달할 반려동물 이름 |
| `enablesQuestionnaire` | Boolean | 아니오 | SDK 문진 사용 여부. 이 샘플 기본값: `true` |
| `enableResultView` | Boolean | 아니오 | SDK 내장 결과 화면 표시 여부. 이 샘플 기본값: `true` |
| `enablePdfShare` | Boolean | 아니오 | 내장 결과 화면의 PDF 공유 버튼 표시 여부. 이 샘플 기본값: `true` |
| `enableMultiMode` | Boolean | 아니오 | Android TTAPI 전용. 최대 4장 촬영을 활성화합니다. 기본값: `false` |

### Android 부위 매핑

Android 브릿지는 Flutter `partType` 값을 네이티브 SDK Activity로 매핑합니다.

| Flutter `partType` | Android SDK Activity | 네이티브 SDK extra |
| --- | --- | --- |
| `EYE` | `EyeCameraActivity` | 없음 |
| `TEETH` | `ToothCameraActivity` | 없음 |
| `EAR` | `SkinCameraActivity` | `partType=EAR` |
| `BODY` | `SkinCameraActivity` | `partType=BELLY` |
| `FOOT` | `SkinCameraActivity` | `partType=FOOT` |

피부 검사는 네이티브 Android SDK 기준으로 `EAR`, `BELLY`, `FOOT` 중 하나가 필요합니다. Flutter 샘플 UI의 `BODY`는 Android의 `BELLY`로 변환됩니다.

## Android 네이티브 SDK Bundle 계약

`android/app/src/main/kotlin/.../MainActivity.kt`를 확장하거나 수정할 때는 아래 Bundle 계약을 기준으로 Android 네이티브 SDK를 호출하세요.

### 필수 필드

| 이름 | 타입 | 설명 |
| --- | --- | --- |
| `petType` | String | `DOG` 또는 `CAT` |
| `userId` | String | 고객사 서비스의 사용자 식별자 |
| `sdkKey` | String | 프로젝트용으로 발급받은 SDK key |

### 피부 검사 시 필수 필드

| 이름 | 타입 | 설명 |
| --- | --- | --- |
| `partType` | String | `SkinCameraActivity` 실행 시 필수. `EAR`, `BELLY`, `FOOT` 중 하나 |

### 선택 필드

| 이름 | 타입 | 기본값 | 설명 |
| --- | --- | --- | --- |
| `petId` | String | 없음 | 고객사 서비스의 반려동물 식별자 |
| `petBirthday` | String | 없음 | 반려동물 생일. `yyyy-MM-dd` 형식 권장 |
| `petBreedName` | String | 없음 | 품종명 |
| `petGender` | String | 없음 | `M`, `F`, `MC`, `FC` |
| `guideUrl` | String | 없음 | SDK 촬영 가이드 웹뷰 URL |
| `isFlashMode` | Boolean | `false` | 촬영 시 플래시 기본 활성화 여부 |
| `enablesQuestionnaire` | Boolean | `true` | SDK 문진 사용 여부 |
| `enableResultView` | Boolean | `true` | SDK 내장 결과 화면 표시 여부 |
| `enablePdfShare` | Boolean | `false` | SDK 결과 화면의 PDF 공유 버튼 표시 여부 |
| `enableMultiMode` | Boolean | `false` | TTAPI에서 최대 4장을 수집·분석할지 여부 |

## Android 네이티브 브릿지 예시

샘플 Android 브릿지는 아래와 같은 Bundle을 생성합니다.

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
    putString("guideUrl", guideUrl)

    if (partType == "EAR" || partType == "BODY" || partType == "FOOT") {
        val nativePartType = if (partType == "BODY") "BELLY" else partType
        putString("partType", nativePartType)
    }
}
```

운영 앱에 적용할 때는 `userId`, `petId`, `petBirthday`, `petBreedName` 같은 샘플 값을 고객사 서비스의 실제 값으로 바꾸세요.

## 옵션 동작

### `enablesQuestionnaire`

- `true`: SDK 문진을 사용하며, 문진 응답이 최종 상태에 반영될 수 있습니다.
- `false`: 문진 없이 진행합니다.

### `enableResultView`

- `true`: SDK 내장 결과 화면을 표시합니다. 사용자가 결과 화면을 닫으면 Flutter로 결과가 반환됩니다.
- `false`: SDK 내장 결과 화면을 표시하지 않고 네이티브 결과 반환 흐름으로 진행합니다.

### `enablePdfShare`

- `true`: SDK 결과 화면에 PDF 공유 버튼을 표시합니다.
- `false`: PDF 공유 버튼을 숨깁니다.

`enablePdfShare`는 `enableResultView=true`일 때 의미가 있습니다.

### `enableMultiMode`

- `false` 또는 미전달: 기존 단건 촬영과 결과 객체 하나를 유지합니다.
- `true` + `analysis_mode=ttapi`: 눈·피부·치아 사진을 최대 4장 수집해 분석합니다.

Android 온디바이스와 하이브리드 분석에는 이 옵션을 적용하지 않습니다. TTAPI 멀티 촬영에서도 채널 반환 타입은 String이지만, 한 장만 제출해도 문자열의 최상위 구조는 촬영 순서의 JSON 배열입니다. 각 항목의 상태를 개별 확인하세요.

## 반환값

채널 반환값은 아래 타입입니다.

```dart
String?
```

반환값이 JSON이면 샘플 앱은 단건 결과 객체 또는 TTAPI 멀티 결과 배열을 들여쓰기 4칸으로 포맷해 Flutter 오버레이에 표시합니다.

## 결과 JSON 개요

SDK 결과 JSON에는 아래 필드가 포함될 수 있습니다.

| 필드 | 설명 |
| --- | --- |
| `status` | SDK 처리 상태. 일반적으로 `SUCCESS` |
| `petType` | `DOG` 또는 `CAT` |
| `part` | 검사 부위. 예: `EYE`, `SKIN`, `TOOTH` |
| `createdAt` | 분석 생성 시각 |
| `questions` | 문진 사용 시 문진 응답 |
| `response` | 사용자 표시용 결과 요약 |
| `userId` | Android 브릿지를 통해 전달한 사용자 식별자 |
| `petId` | Android 브릿지를 통해 전달한 반려동물 식별자 |
| `subPart` | 가능한 경우 `EYEL`, `EAR`, `TCENTER` 같은 상세 위치 코드 |

공개 결과 JSON에는 더 이상 `metadata` 객체가 포함되지 않습니다. `score`, `predValues`, `pred_values`, `modelName` 같은 내부 모델 필드는 Flutter로 반환되지 않습니다.

`response.status`는 아래 중 하나입니다.

| 상태 | 의미 |
| --- | --- |
| `NORMAL` | 이상 징후가 감지되지 않은 상태 |
| `CAUTION` | 관찰이 권장되는 상태 |
| `WARNING` | 후속 확인이 권장되는 상태 |

`enablesQuestionnaire=true`인 경우 Android SDK는 문진 응답과 AI 스캔 결과를 조합하여 최종 상태를 결정합니다.

| 문진 응답 | AI 스캔 결과 | 최종 상태 |
| --- | --- | --- |
| 증상 있음 | 이상 징후 감지 | `WARNING` |
| 증상 없음 | 이상 징후 감지 | `CAUTION` |
| 증상 없음 | 이상 징후 없음 | `NORMAL` |
| 증상 있음 | 이상 징후 없음 | `CAUTION` |

### 상세 결과 블록

`questions`에는 문진 플로우가 활성화된 경우 문진 응답이 포함됩니다.

| 필드 | 설명 |
| --- | --- |
| `text` | 문진 질문 텍스트 |
| `select` | 사용자 응답. `Y` 또는 `N` |

`response.description`은 UI 표시를 위한 결과 수준의 안내 문구입니다.

| 필드 | 설명 |
| --- | --- |
| `title` | 안내 제목 |
| `contents` | 안내 본문 목록 |

감지된 증상에는 모델 출력값과 이미지 URL이 포함됩니다.

| 필드 | 설명 |
| --- | --- |
| `abnormLevel` | SDK가 계산한 이상 수준 |
| `cropImageUrl` | 크롭 이미지 HTTPS URL |
| `heatmapUrl` | 히트맵 이미지 HTTPS URL |
| `isAbnormal` | 해당 증상이 이상으로 판단되었는지 여부 |
| `resultLabel` | `normal`, `abnormal` 등의 결과 라벨 |
| `details` | 증상 설명 블록 |

`response.symptoms[].details`에는 아래 키가 사용됩니다.

| Key | 설명 |
| --- | --- |
| `what_it_is` | 감지된 증상에 대한 일반 설명 |
| `related_clinical_conditions` | 파트너용 관련 질환 및 요인 |
| `possible_causes` | 보호자용 가능한 원인 |
| `what_you_can_do` | 홈케어 및 관찰 가이드 |

### 부위(Position) 코드

| 코드 | 검사 종류 | 설명 |
| --- | --- | --- |
| `EYER` | 눈 | 오른쪽 눈 |
| `EYEL` | 눈 | 왼쪽 눈 |
| `EAR` | 피부 | 귀 |
| `BELLY` | 피부 | 복부 |
| `FOOT` | 피부 | 발 |
| `TCENTER` | 치아 | 앞니 |
| `TRIGHT` | 치아 | 오른쪽 치아 |
| `TLEFT` | 치아 | 왼쪽 치아 |

결과 이미지는 원격 URL입니다. Flutter에서 반환된 이미지를 표시할 때는 URL을 그대로 로드하세요.

```dart
Image.network(heatmapUrl);
```

### 샘플 결과 JSON

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
    { "text": "동공 크기가 서로 다른가요?", "select": "N" }
  ],
  "response": {
    "status": "WARNING",
    "title": "가능한 한 빠른 동물병원 진료를 권장해요.",
    "analyzedDate": "2026. 06. 15 10:00",
    "description": {
      "title": "동물병원 내원이 필요한 경우",
      "contents": [
        "눈을 찡그리거나 깜빡이는 증상이 호전되지 않는 경우",
        "충혈, 부기, 분비물이 지속되거나 악화되는 경우"
      ]
    },
    "symptoms": [
      {
        "code": "opacity",
        "abnormLevel": 1,
        "cropImageUrl": "https://cdn-results.ai4pet.com/.../diagnosis_crop",
        "name": "혼탁",
        "isAbnormal": true,
        "resultLabel": "abnormal",
        "heatmapUrl": "https://cdn-results.ai4pet.com/.../diagnosis_heatmap",
        "details": [
          {
            "key": "what_it_is",
            "title": "이 증상은 무엇인가요",
            "contents": ["눈 표면이 뿌옇거나 흐릿하게 보이는 상태예요."]
          }
        ]
      }
    ]
  }
}
```

## SDK key 설정

Flutter 샘플은 `launchSdk` MethodChannel 호출을 통해 Android SDK key를 전달합니다.

```dart
const String _kSdkKey = 'Enter your issued SDK key';
```

Android 샘플 흐름을 실행하기 전에 플레이스홀더를 프로젝트용으로 발급받은 SDK key로 교체하세요. 실제 운영용 SDK key를 공개 소스 코드에 커밋하지 말고, 고객사 보안 정책에 맞게 안전하게 로드하세요.

## iOS 설정

Xcode에서 `ios/Runner.xcworkspace`를 열고 Runner 타겟의 **Signing & Capabilities**에서 Apple Development Team을 선택하세요.

iOS 샘플은 `AIScan 2.0.3`을 사용합니다.

## Android ProGuard / R8

R8 minification을 적용하는 release 빌드는 JNI 참조 클래스 keep rule이 필요합니다. 샘플에는 `android/app/proguard-rules.pro`에 필요한 규칙이 이미 포함되어 있고 release 빌드 타입에 연결되어 있습니다.

## 실행

```bash
flutter pub get
flutter run
```

## 검증

```bash
flutter analyze
flutter test
```
