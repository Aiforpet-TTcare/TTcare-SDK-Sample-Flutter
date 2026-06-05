# fluttersdksample

🌐 [English](README.md) · [한국어](README.ko.md) · **日本語**

aiforpet 診断 SDK を呼び出す Flutter デモアプリ。
ホストネイティブ(Android / iOS)が公開する `MethodChannel` 経由で SDK のエントリポイントを呼び出し、返却された JSON 結果を画面に表示する。

ネイティブ SDK バージョン: Android `scansdk-lib:2.1.0`, iOS `AIScan 2.0.3`.
Android SDK 2.1.0 は、結果画面のローカライズとして英語、韓国語、日本語、イタリア語、スウェーデン語、タイ語をサポートします。
Android は Android 9.0+ (`minSdk 28`) が必要です。

## 概要

- 画面上部: SDK オプション切り替えトグル 3 つ (`enableQuestionnaire`, `enableResultView`, `enablePdfShare`)
- 画面本体: ペット種別(DOG / CAT)ごとの診断部位カード
  - DOG: `EYE`, `EAR`, `BODY`, `FOOT`, `TEETH`
  - CAT: `EYE`, `TEETH`
- カードをタップするとネイティブチャネル経由で `launchSdk` を呼び出し、結果を JSON 整形してオーバーレイ表示する。

## MethodChannel 仕様

| 項目 | 値 |
| --- | --- |
| チャネル名 | `com.aiforpet.sdk/channel` |
| メソッド | `launchSdk` |

### 引数

```json
{
  "petType": "DOG | CAT",
  "partType": "EYE | EAR | BODY | FOOT | TEETH",
  "enablesQuestionnaire": true,
  "enableResultView": true,
  "enablePdfShare": true
}
```

`enablePdfShare` は Android SDK 2.1.0 のオプションで、内蔵結果画面に PDF 共有ボタンを表示するかどうかを制御します。

### 戻り値

`String?` — SDK の結果。JSON ならインデント 4 スペースで整形して表示し、そうでなければ raw テキストとして表示する。

## 事前準備

### 1. SDK 認証設定

`assets/auth-config.json.example` をコピーして `assets/auth-config.json` を作成し、発行された認証情報を埋める。

```bash
cp assets/auth-config.json.example assets/auth-config.json
# エディタで clientId / clientKeyId / clientKeySecret / clientKey を入力
```

> ⚠️ `assets/auth-config.json` は `.gitignore` に登録済み。秘密鍵を含むため **絶対にコミット禁止**。

### 2. iOS 署名

`ios/Runner.xcworkspace` を Xcode で開き、Runner ターゲットの **Signing & Capabilities** で自分の Apple Development Team を選択する (Automatic signing)。

### 3. Android ProGuard ルール (release ビルド)

R8 minification を適用する release ビルドでは、JNI 参照クラス (ONNX Runtime、LiteRT、AIScan SDK) に対する keep ルールが必須。`android/app/proguard-rules.pro` に既に定義済みで release ビルドタイプに接続されているため、追加対応は不要。

## 実行

```bash
flutter pub get
flutter run                 # debug
flutter run --release       # release (ProGuard ルール検証)
```

ホストネイティブ側に上記チャネルを処理するハンドラが実装されている必要がある。

## 検証

```bash
flutter analyze
flutter test
```
