# TTcare Flutter SDK Sample

🌐 [English](README.md) · **한국어** · [日本語](README.ja.md)

이 샘플은 Flutter 앱에서 `MethodChannel`을 통해 TTcare 네이티브 Scan SDK를 실행하고, SDK가 반환한 결과 JSON을 Flutter 화면에 표시하는 예제입니다.

이 README는 Flutter 연동자가 Android 샘플 README를 따로 열지 않아도 Android 네이티브 SDK 브릿지 구조와 파라미터를 이해할 수 있도록 작성되었습니다.

## 네이티브 SDK 버전

| 플랫폼 | 네이티브 SDK |
| --- | --- |
| Android | `io.github.aiforpet-ttcare:scansdk-lib:2.1.0` |
| iOS | `AIScan 2.0.3` |

Android는 Android 9.0 이상(`minSdk 28`)이 필요합니다. Android SDK 2.1.0은 결과 화면에서 영어, 한국어, 일본어, 이탈리아어, 스웨덴어, 태국어 현지화를 지원합니다.

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
  "authConfig": "{ TTcare auth JSON string }"
}
```

### 인자 설명

| 이름 | 타입 | 필수 | 설명 |
| --- | --- | --- | --- |
| `petType` | String | 예 | `DOG` 또는 `CAT` |
| `partType` | String | 예 | Flutter 샘플 값: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH` |
| `authConfig` | String | 예 | `assets/auth-config.json`에서 읽은 TTcare 인증 JSON 문자열 |
| `enablesQuestionnaire` | Boolean | 아니오 | SDK 문진 사용 여부. 이 샘플 기본값: `true` |
| `enableResultView` | Boolean | 아니오 | SDK 내장 결과 화면 표시 여부. 이 샘플 기본값: `true` |
| `enablePdfShare` | Boolean | 아니오 | 내장 결과 화면의 PDF 공유 버튼 표시 여부. 이 샘플 기본값: `true` |

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
| `ttConf` | String | TTcare 인증 JSON 문자열 |

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
| `petAdditionalInfo` | String | 없음 | 추가 메타데이터. JSON 문자열 권장 |
| `guideUrl` | String | 없음 | SDK 촬영 가이드 웹뷰 URL |
| `isFlashMode` | Boolean | `false` | 촬영 시 플래시 기본 활성화 여부 |
| `enablesQuestionnaire` | Boolean | `true` | SDK 문진 사용 여부 |
| `enableResultView` | Boolean | `true` | SDK 내장 결과 화면 표시 여부 |
| `enablePdfShare` | Boolean | `false` | SDK 결과 화면의 PDF 공유 버튼 표시 여부 |

## Android 네이티브 브릿지 예시

샘플 Android 브릿지는 아래와 같은 Bundle을 생성합니다.

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

## 반환값

채널 반환값은 아래 타입입니다.

```dart
String?
```

반환값이 JSON이면 샘플 앱은 들여쓰기 4칸으로 포맷해 Flutter 오버레이에 표시합니다.

## 결과 JSON 개요

SDK 결과 JSON에는 아래 필드가 포함될 수 있습니다.

| 필드 | 설명 |
| --- | --- |
| `status` | SDK 처리 상태. 일반적으로 `SUCCESS` |
| `petType` | `DOG` 또는 `CAT` |
| `part` | 검사 부위. 예: `EYE`, `SKIN`, `TOOTH` |
| `createdAt` | 분석 생성 시각 |
| `subPart` | 상세 위치. 예: `EYER`, `EYEL`, `EAR`, `BELLY`, `FOOT`, `TCENTER` |
| `userId` | 호스트 앱에서 전달한 사용자 ID |
| `questions` | 문진 사용 시 문진 응답 |
| `metadata` | 호스트 앱에서 전달한 반려동물 메타데이터 |
| `response` | 사용자 표시용 결과 요약 |

`response.status`는 아래 중 하나입니다.

| 상태 | 의미 |
| --- | --- |
| `NORMAL` | 이상 징후가 감지되지 않은 상태 |
| `CAUTION` | 관찰이 권장되는 상태 |
| `WARNING` | 후속 확인이 권장되는 상태 |

감지된 증상에는 로컬 파일 경로가 포함될 수 있습니다.

| 필드 | 설명 |
| --- | --- |
| `heatmapPath` | 히트맵 이미지 로컬 경로. `file://...` |
| `cropImageUrl` | 크롭 이미지 로컬 경로. `file://...` |

이 값들은 원격 URL이 아니라 앱 sandbox 내부의 로컬 파일입니다. 이미지를 보관하거나 업로드해야 한다면 SDK 생성 파일을 정리하기 전에 복사 또는 업로드하세요.

## SDK 인증 설정

`assets/auth-config.json.example`을 복사해 `assets/auth-config.json`을 만들고 발급받은 인증 정보를 채우세요.

```bash
cp assets/auth-config.json.example assets/auth-config.json
```

`assets/auth-config.json`은 secret을 포함하므로 Git에서 제외되어 있습니다. 실제 인증 정보를 커밋하지 마세요.

운영 앱에서는 인증 JSON을 assets에 평문으로 두기보다 고객사 보안 정책에 맞게 안전하게 로드하세요.

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
