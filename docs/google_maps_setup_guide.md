# Google Maps Setup Guide for Nike+ Clone

このアプリケーションはGoogle Maps SDKを使用して、ワークアウトルートを表示します。以下の手順に従って、開発環境を設定してください。

## Google Maps API Keyの取得

1. [Google Cloud Platform Console](https://console.cloud.google.com/)にアクセスします
2. プロジェクトを作成または選択します
3. 「APIとサービス」→「ライブラリ」から以下のAPIを有効にします：
   - Maps SDK for iOS
   - Maps SDK for Android
4. 「APIとサービス」→「認証情報」からAPIキーを作成します
5. 作成したAPIキーを制限することをお勧めします：
   - iOSアプリケーション：アプリのバンドルID
   - Androidアプリケーション：アプリのパッケージ名

## iOSの設定

1. `ios/Runner/Info.plist`にAPIキーを設定します：
   ```xml
   <key>GoogleMapsAPIKey</key>
   <string>YOUR_API_KEY_HERE</string>
   ```

2. `ios/Podfile`にGoogle Maps SDKを追加します：
   ```ruby
   target 'Runner' do
     use_frameworks!
     
     pod 'GoogleMaps'  # GoogleMaps SDKを明示的に追加
     flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
     # ...
   end
   ```

3. 依存関係をインストールします：
   ```bash
   cd ios
   pod install
   ```

## Androidの設定

1. `android/app/src/main/AndroidManifest.xml`にAPIキーを設定します：
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE" />
   ```

2. `android/local.properties`ファイルで環境変数を設定することもできます：
   ```
   MAPS_API_KEY=YOUR_API_KEY_HERE
   ```

## トラブルシューティング

### iOSビルドエラー: No such module 'GoogleMaps'

このエラーが発生した場合は、以下の手順を試してください：

1. Podfileに`pod 'GoogleMaps'`が追加されていることを確認します
2. ターミナルで以下のコマンドを実行します：
   ```bash
   cd ios
   pod install
   ```
3. Xcodeプロジェクトを閉じて再度開きます
4. Xcodeで「Product」→「Clean Build Folder」を選択します
5. 再度ビルドを実行します

### Androidビルドエラー: API key not found

このエラーが発生した場合は、以下の手順を試してください：

1. `android/local.properties`ファイルにAPIキーが設定されていることを確認します
2. `android/app/src/main/AndroidManifest.xml`ファイルのAPIキー設定を確認します
3. Android Studioでプロジェクトを再同期します
