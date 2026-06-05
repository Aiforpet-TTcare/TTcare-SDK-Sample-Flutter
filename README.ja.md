# TTcare Flutter SDK Sample

🌐 [English](README.md) · [한국어](README.ko.md) · **日本語**

このサンプルは、Flutter アプリから `MethodChannel` 経由で TTcare ネイティブ Scan SDK を起動し、SDK が返す結果 JSON を Flutter 画面に表示する例です。

この README は、Flutter 連携担当者が Android サンプル README を別途開かなくても、Android ネイティブ SDK ブリッジの構造とパラメータを理解できるように作成されています。

## ネイティブ SDK バージョン

| プラットフォーム | ネイティブ SDK |
| --- | --- |
| Android | `io.github.aiforpet-ttcare:scansdk-lib:2.1.0` |
| iOS | `AIScan 2.0.3` |

Android は Android 9.0+ (`minSdk 28`) が必要です。Android SDK 2.1.0 は、結果画面のローカライズとして英語、韓国語、日本語、イタリア語、スウェーデン語、タイ語をサポートします。

## このサンプルが提供するもの

- ペット種別と検査部位を選択する Flutter UI
- ネイティブ SDK オプショントグル
- TTcare Android SDK Activity を起動する Android ネイティブブリッジ
- iOS `AIScan` 連携の開始点
- Flutter JSON 結果オーバーレイ
- Android release ビルド向け ProGuard/R8 ルール

## 画面フロー

- 画面上部: SDK オプショントグル
  - `enableQuestionnaire`
  - `enableResultView`
  - `enablePdfShare`
- 画面本体: ペット種別と検査部位カード
  - DOG: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH`
  - CAT: `EYE`, `TEETH`
- カードをタップすると、ネイティブチャネルで `launchSdk` を呼び出します。
- ネイティブレイヤーが検査部位に応じた SDK カメラ Activity を起動します。
- SDK 結果が Flutter に返され、JSON として表示されます。

## MethodChannel 契約

| 項目 | 値 |
| --- | --- |
| Channel | `com.aiforpet.sdk/channel` |
| Method | `launchSdk` |

### Flutter 引数

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

### 引数詳細

| 名前 | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| `petType` | String | はい | `DOG` または `CAT` |
| `partType` | String | はい | Flutter サンプル値: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH` |
| `authConfig` | String | はい | `assets/auth-config.json` から読み込む TTcare 認証 JSON 文字列 |
| `enablesQuestionnaire` | Boolean | いいえ | SDK 問診を使用するか。サンプルのデフォルト: `true` |
| `enableResultView` | Boolean | いいえ | SDK 内蔵結果画面を表示するか。サンプルのデフォルト: `true` |
| `enablePdfShare` | Boolean | いいえ | 内蔵結果画面に PDF 共有ボタンを表示するか。サンプルのデフォルト: `true` |

### Android 部位マッピング

Android ブリッジは Flutter の `partType` 値をネイティブ SDK Activity にマッピングします。

| Flutter `partType` | Android SDK Activity | ネイティブ SDK extra |
| --- | --- | --- |
| `EYE` | `EyeCameraActivity` | なし |
| `TEETH` | `ToothCameraActivity` | なし |
| `EAR` | `SkinCameraActivity` | `partType=EAR` |
| `BODY` | `SkinCameraActivity` | `partType=BELLY` |
| `FOOT` | `SkinCameraActivity` | `partType=FOOT` |

皮膚検査では、ネイティブ Android SDK 側で `EAR`, `BELLY`, `FOOT` のいずれかが必要です。Flutter サンプル UI の `BODY` は Android の `BELLY` に変換されます。

## Android ネイティブ SDK Bundle 契約

`android/app/src/main/kotlin/.../MainActivity.kt` を拡張または修正する場合は、以下の Bundle 契約を基準に Android ネイティブ SDK を呼び出してください。

### 必須フィールド

| 名前 | 型 | 説明 |
| --- | --- | --- |
| `petType` | String | `DOG` または `CAT` |
| `userId` | String | パートナーサービスのユーザー識別子 |
| `ttConf` | String | TTcare 認証 JSON 文字列 |

### 皮膚検査時の必須フィールド

| 名前 | 型 | 説明 |
| --- | --- | --- |
| `partType` | String | `SkinCameraActivity` 起動時に必須。`EAR`, `BELLY`, `FOOT` のいずれか |

### オプションフィールド

| 名前 | 型 | デフォルト | 説明 |
| --- | --- | --- | --- |
| `petId` | String | なし | パートナーサービスのペット識別子 |
| `petBirthday` | String | なし | ペットの誕生日。`yyyy-MM-dd` 形式推奨 |
| `petBreedName` | String | なし | 品種名 |
| `petGender` | String | なし | `M`, `F`, `MC`, `FC` |
| `petAdditionalInfo` | String | なし | 追加メタデータ。JSON 文字列推奨 |
| `guideUrl` | String | なし | SDK 撮影ガイド WebView URL |
| `isFlashMode` | Boolean | `false` | 撮影時にフラッシュを初期有効にするか |
| `enablesQuestionnaire` | Boolean | `true` | SDK 問診を使用するか |
| `enableResultView` | Boolean | `true` | SDK 内蔵結果画面を表示するか |
| `enablePdfShare` | Boolean | `false` | SDK 結果画面に PDF 共有ボタンを表示するか |

## Android ネイティブブリッジ例

サンプル Android ブリッジは以下のような Bundle を生成します。

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

本番アプリに適用する場合は、`userId`, `petId`, `petBirthday`, `petBreedName` などのサンプル値を自社サービスの実データに置き換えてください。

## オプション動作

### `enablesQuestionnaire`

- `true`: SDK 問診を使用し、問診回答が最終状態に反映される場合があります。
- `false`: 問診なしで進行します。

### `enableResultView`

- `true`: SDK 内蔵結果画面を表示します。ユーザーが結果画面を閉じると Flutter に結果が返ります。
- `false`: SDK 内蔵結果画面を表示せず、ネイティブ結果返却フローで進行します。

### `enablePdfShare`

- `true`: SDK 結果画面に PDF 共有ボタンを表示します。
- `false`: PDF 共有ボタンを非表示にします。

`enablePdfShare` は `enableResultView=true` の場合に有効です。

## 戻り値

チャネルの戻り値は以下の型です。

```dart
String?
```

戻り値が JSON の場合、サンプルアプリは 4 スペースで整形して Flutter オーバーレイに表示します。

## 結果 JSON 概要

SDK 結果 JSON には以下のフィールドが含まれる場合があります。

| フィールド | 説明 |
| --- | --- |
| `status` | SDK 処理状態。通常は `SUCCESS` |
| `petType` | `DOG` または `CAT` |
| `part` | 検査部位。例: `EYE`, `SKIN`, `TOOTH` |
| `createdAt` | 解析生成時刻 |
| `subPart` | 詳細位置。例: `EYER`, `EYEL`, `EAR`, `BELLY`, `FOOT`, `TCENTER` |
| `userId` | ホストアプリから渡したユーザー ID |
| `questions` | 問診使用時の問診回答 |
| `metadata` | ホストアプリから渡したペットメタデータ |
| `response` | ユーザー表示用の結果要約 |

`response.status` は以下のいずれかです。

| 状態 | 意味 |
| --- | --- |
| `NORMAL` | 異常兆候が検出されていない状態 |
| `CAUTION` | 観察が推奨される状態 |
| `WARNING` | 追加確認が推奨される状態 |

検出された症状にはローカルファイルパスが含まれる場合があります。

| フィールド | 説明 |
| --- | --- |
| `heatmapPath` | ヒートマップ画像のローカルパス。`file://...` |
| `cropImageUrl` | クロップ画像のローカルパス。`file://...` |

これらはリモート URL ではなく、アプリ sandbox 内のローカルファイルです。画像を保持またはアップロードする必要がある場合は、SDK 生成ファイルを削除する前にコピーまたはアップロードしてください。

## SDK 認証設定

`assets/auth-config.json.example` をコピーして `assets/auth-config.json` を作成し、発行された認証情報を入力してください。

```bash
cp assets/auth-config.json.example assets/auth-config.json
```

`assets/auth-config.json` は secret を含むため Git から除外されています。実際の認証情報をコミットしないでください。

本番アプリでは、認証 JSON を assets に平文で置くのではなく、パートナーアプリのセキュリティポリシーに合わせて安全に読み込んでください。

## iOS 設定

Xcode で `ios/Runner.xcworkspace` を開き、Runner ターゲットの **Signing & Capabilities** で Apple Development Team を選択してください。

iOS サンプルは `AIScan 2.0.3` を使用します。

## Android ProGuard / R8

R8 minification を適用する release ビルドでは、JNI 参照クラスの keep rule が必要です。サンプルには `android/app/proguard-rules.pro` に必要なルールがすでに含まれており、release ビルドタイプに接続されています。

## 実行

```bash
flutter pub get
flutter run
```

## 検証

```bash
flutter analyze
flutter test
```
