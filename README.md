# fluttersdksample

aiforpet 진단 SDK를 호출하기 위한 Flutter 데모 앱.
호스트 네이티브(Android/iOS) 앱이 노출하는 `MethodChannel`로 SDK 진입점을 호출하고, 반환된 JSON 결과를 화면에 표시한다.

## 동작 개요

- 화면 상단: 두 개의 SDK 옵션 토글 (`enableQuestionnaire`, `enableResultView`)
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
  "enableResultView": true
}
```

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

## 실행

```bash
flutter pub get
flutter run
```

호스트 네이티브 측에 위 채널을 처리하는 핸들러가 구현되어 있어야 정상 동작한다.

## 검증

```bash
flutter analyze
flutter test
```
