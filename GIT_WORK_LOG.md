# Git Work Log

### [2026-10-20 09:45 KST] Flutter Android SDK 2.2.3 및 TTAPI 멀티 촬영 예제
- **브랜치:** `codex/public-android-2.2.3-flutter-20261020`을 `origin/main`에서 생성하고 원격 브랜치 등록.
- **변경:** Android 네이티브 SDK를 2.2.3으로 갱신하고, Dart 옵션을 MethodChannel과 Android Bundle의 `enableMultiMode` Boolean으로 연결함. iOS SDK 버전과 호출 계약은 변경하지 않음.
- **외부 계약:** Android TTAPI에서만 최대 4장의 배열 결과를 사용하며, 기본 false와 기존 단건 결과 계약을 유지함.
- **검증:** `flutter test`(3개), `flutter analyze`, `flutter build apk --debug`, `git diff --check` 통과. 실제 라이선스 키 패턴 없음.
- **상태:** 이 변경 커밋을 작업 브랜치에 푸시함. main 병합 및 배포 없음.
