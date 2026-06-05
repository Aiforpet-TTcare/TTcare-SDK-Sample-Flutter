# fluttersdksample

🌐 [English](README.md) · **한국어** · [日本語](README.ja.md)

aiforpet 진단 SDK를 호출하기 위한 Flutter 데모 앱.
호스트 네이티브(Android / iOS) 앱이 노출하는 `MethodChannel`로 SDK 진입점을 호출하고, 반환된 JSON 결과를 화면에 표시한다.

네이티브 SDK 버전: Android `scansdk-lib:2.1.0`, iOS `AIScan 2.0.3`.
Android SDK 2.1.0은 결과 화면에서 영어, 한국어, 일본어, 이탈리아어, 스웨덴어, 태국어 현지화를 지원한다.
Android는 Android 9.0 이상(`minSdk 28`)이 필요하다.

## 동작 개요

- 화면 상단: 세 개의 SDK 옵션 토글 (`enableQuestionnaire`, `enableResultView`, `enablePdfShare`)
- 화면 본문: 펫 종류(DOG / CAT)별 진단 부위 카드
  - DOG: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH`
  - CAT: `EYE`, `TEETH`
- 카드 탭 시 네이티브 채널로 `launchSdk` 호출 → 결과 오버레이로 JSON 포맷 출력

## MethodChannel 사양

| 항목 | 값 |
| --- | --- |
| 채널명 | `com.aiforpet.sdk/channel` |
| 메서드 | `launchSdk` |

### 인자

```json
{
  "petType": "DOG | CAT",
  "partType": "EYE | EAR | BODY | FOOT | TEETH",
  "enablesQuestionnaire": true,
  "enableResultView": true,
  "enablePdfShare": true
}
```

`enablePdfShare`는 Android SDK 2.1.0 옵션이며, 내장 결과 화면에서 PDF 공유 버튼을 표시할지 제어한다.

### 반환값

`String?` — SDK 결과. JSON이면 들여쓰기 4칸으로 포맷되어 화면에 표시되고, 아니면 raw 텍스트로 노출된다.

## 사전 설정

### 1. SDK 인증 설정

`assets/auth-config.json.example`을 복사하여 `assets/auth-config.json`을 만들고 발급받은 자격증명을 채운다.

```bash
cp assets/auth-config.json.example assets/auth-config.json
# editor로 clientId / clientKeyId / clientKeySecret / clientKey 채움
```

> ⚠️ `assets/auth-config.json`은 `.gitignore`에 등록되어 있다. 비밀키 포함 → **절대 커밋 금지**.

### 2. iOS 서명

`ios/Runner.xcworkspace`를 Xcode에서 열고 Runner 타겟의 **Signing & Capabilities**에서 본인 Apple Development Team을 선택한다 (Automatic signing).

### 3. Android ProGuard 룰 (release 빌드)

R8 minification 적용 release 빌드는 JNI 참조 클래스(ONNX Runtime, LiteRT, AIScan SDK)에 keep 룰이 필요하다. `android/app/proguard-rules.pro`에 이미 정의되어 있고 release 빌드 타입에 연결되어 있으므로 추가 조치 불필요.

## 실행

```bash
flutter pub get
flutter run                 # debug
flutter run --release       # release (ProGuard 룰 검증)
```

호스트 네이티브 측에 위 채널을 처리하는 핸들러가 구현되어 있어야 정상 동작한다.

## 검증

```bash
flutter analyze
flutter test
```
