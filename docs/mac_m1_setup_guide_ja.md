# Nike+ Clone アプリ: Mac M1 セットアップガイド

このガイドでは、Mac M1マシンでNike+ Clone Flutterアプリケーションをセットアップして実行するための手順を詳しく説明します。開発環境の構成、依存関係のインストール、アプリケーションの実行方法について、以下の手順に従ってください。

## 目次

1. [Flutter開発環境のセットアップ](#flutter開発環境のセットアップ)
2. [プロジェクトのセットアップ](#プロジェクトのセットアップ)
3. [Google Maps APIの設定](#google-maps-apiの設定)
4. [アプリケーションの実行](#アプリケーションの実行)
5. [テスト手順](#テスト手順)
6. [トラブルシューティング](#トラブルシューティング)

## Flutter開発環境のセットアップ

### 1. Homebrewのインストール

Homebrewは、macOSのパッケージマネージャーで、開発ツールを簡単にインストールできます。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

インストール後、PATHにHomebrewを追加します：

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Gitのインストール

```bash
brew install git
```

### 3. Flutterのインストール

```bash
# Homebrewを使用してFlutterをインストール
brew install --cask flutter

# インストールを確認
flutter doctor
```

次に進む前に、`flutter doctor`で報告された問題を解決してください。

### 4. Xcodeのインストール

1. Mac App StoreからXcodeをダウンロードしてインストール
2. Xcodeコマンドラインツールをインストール：

```bash
xcode-select --install
```

3. Xcodeライセンスに同意：

```bash
sudo xcodebuild -license accept
```

4. FlutterのためにXcodeを設定：

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### 5. Android Studioのインストール

1. [developer.android.com](https://developer.android.com/studio)からAndroid Studioをダウンロード
2. Android Studioをインストールして開く
3. セットアップウィザードで以下をインストール：
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
4. FlutterのためにAndroid Studioを設定：
   - FlutterとDartプラグインをインストール：
     - Android Studioを開く
     - 環境設定 > プラグインに移動
     - 「Flutter」を検索してインストール（Dartプラグインも一緒にインストールされます）
     - Android Studioを再起動

### 6. CocoaPodsのインストール

CocoaPodsはiOS開発に必要です：

```bash
sudo gem install cocoapods
```

M1 Macの場合、以下を使用する必要があるかもしれません：

```bash
sudo arch -x86_64 gem install ffi
sudo arch -x86_64 gem install cocoapods
```

## プロジェクトのセットアップ

### 1. リポジトリのクローン

```bash
git clone https://github.com/dmasubuchi/nikemon.git
cd nikemon
```

### 2. 依存関係のインストール

```bash
flutter pub get
```

### 3. iOSのセットアップ

```bash
cd ios
pod install
cd ..
```

M1でCocoaPodsに問題がある場合は、次を試してください：

```bash
cd ios
arch -x86_64 pod install
cd ..
```

## Google Maps APIの設定

Nike+ Cloneアプリはワークアウトルートの表示にGoogle Mapsを使用します。Google Maps APIキーを設定する必要があります：

### 1. Google Maps APIキーの取得

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成するか、既存のプロジェクトを選択
3. 以下のAPIを有効化：
   - Maps SDK for Android
   - Maps SDK for iOS
4. 認証情報セクションでAPIキーを作成
5. セキュリティのため、APIキーをMaps SDKsのみに制限

### 2. Androidの設定

1. `android/app/src/main/AndroidManifest.xml`ファイルを開く
2. `android:name="com.google.android.geo.API_KEY"`を持つ`<meta-data>`タグを見つける
3. `android:value="YOUR_API_KEY_HERE"`を実際のAPIキーに置き換え：

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="実際のAPIキーをここに入力" />
```

### 3. iOSの設定

1. `ios/Runner/AppDelegate.swift`ファイルを開く
2. 以下の内容を確認：

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

3. `"YOUR_API_KEY_HERE"`を実際のAPIキーに置き換え

4. `ios/Runner/Info.plist`を開き、以下を追加：

```xml
<key>GoogleMapsAPIKey</key>
<string>実際のAPIキーをここに入力</string>
```

5. また、`Info.plist`に以下の権限が含まれていることを確認：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>このアプリはワークアウトを追跡するために、開いているときに位置情報へのアクセスが必要です。</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>このアプリはワークアウトを追跡するために、バックグラウンドでも位置情報へのアクセスが必要です。</string>
```

## アプリケーションの実行

### 1. iOSシミュレータの起動

```bash
open -a Simulator
```

### 2. アプリの実行

```bash
flutter run
```

特定のデバイスで実行するには：

```bash
# 利用可能なデバイスを一覧表示
flutter devices

# 特定のデバイスで実行
flutter run -d <device_id>
```

## テスト手順

### 1. 基本機能のテスト

1. **ホーム画面のナビゲーション**：
   - 下部ナビゲーションバーが正しく機能することを確認
   - すべてのタブ（ホーム、ワークアウト、履歴、設定）にアクセスできることを確認

2. **ワークアウトトラッキング**：
   - 新しいワークアウトを開始
   - GPSトラッキングが開始されることを確認
   - 距離、ペース、時間のメトリクスがリアルタイムで更新されることを確認
   - ワークアウトの一時停止と再開をテスト
   - ワークアウトを停止し、結果画面への遷移を確認

3. **結果画面**：
   - すべてのワークアウトメトリクスが正しく表示されることを確認
   - ルートマップが正しい経路を表示することを確認
   - 保存機能をテスト
   - ホーム画面への戻りナビゲーションを確認

4. **履歴画面**：
   - 保存されたワークアウトがリストに表示されることを確認
   - ワークアウトが日付順（最新順）にソートされていることを確認
   - ワークアウトをタップして詳細を表示するテスト
   - ワークアウトの削除をテスト

5. **設定画面**：
   - デバッグモードのオン/オフを切り替え
   - 履歴クリア機能をテスト

### 2. 位置情報権限のテスト

1. プロンプトが表示されたら位置情報の権限を拒否
2. 適切なエラーメッセージが表示されることを確認
3. 権限を付与し、アプリが正しく動作することを確認

### 3. マップ表示のテスト

1. GPSトラッキングでワークアウトを完了
2. ルートがマップ上に正しく表示されることを確認
3. 開始点と終了点のマーカーが正しく配置されていることを確認

## トラブルシューティング

### 一般的な問題と解決策

#### Flutterインストールの問題

**問題**: Flutter doctorがXcodeやAndroid Studioに関する問題を表示する。  
**解決策**: 各ツールのセットアップステップをすべて完了し、すべてのライセンスに同意していることを確認してください。

```bash
flutter doctor --android-licenses
sudo xcodebuild -license accept
```

#### M1でのCocoaPods問題

**問題**: `pod install`がアーキテクチャ関連のエラーで失敗する。  
**解決策**: アーキテクチャフラグを使用：

```bash
arch -x86_64 pod install
```

#### Google Mapsが表示されない

**問題**: マップがグレー画面またはエラーメッセージを表示する。  
**解決策**: 
1. APIキーがAndroidとiOSの両方の設定で正しく設定されていることを確認
2. Google Cloud ConsoleでGoogle Maps APIが有効になっていることを確認
3. APIキーに正しい制限が設定されていることを確認

#### 位置情報トラッキングの問題

**問題**: アプリが位置情報を追跡しない、または不正確なデータを表示する。  
**解決策**:
1. 位置情報の権限が付与されていることを確認
2. デバイスで位置情報サービスが有効になっていることを確認
3. iOSシミュレータの場合、位置情報をシミュレートできます：
   - シミュレータで、機能 > 位置情報 > カスタム位置情報に移動
   - 座標を入力すると、シミュレータがそれを使用します

#### ビルドエラー

**問題**: パッケージ関連のエラーでアプリのビルドが失敗する。  
**解決策**: プロジェクトをクリーンにして依存関係を再取得してみてください：

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

追加のヘルプが必要な場合や問題を報告するには、[GitHubリポジトリ](https://github.com/dmasubuchi/nikemon)で問題を作成してください。
