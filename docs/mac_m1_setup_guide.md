# Nike+ Clone App: Mac M1 Setup Guide

This guide provides step-by-step instructions for setting up and running the Nike+ Clone Flutter application on Mac M1 machines. Follow these instructions to configure your development environment, install dependencies, and run the application.

## Table of Contents

1. [Flutter Development Environment Setup](#flutter-development-environment-setup)
2. [Project Setup](#project-setup)
3. [Google Maps API Configuration](#google-maps-api-configuration)
4. [Running the Application](#running-the-application)
5. [Testing Procedures](#testing-procedures)
6. [Troubleshooting](#troubleshooting)

## Flutter Development Environment Setup

### 1. Install Homebrew

Homebrew is a package manager for macOS that makes it easy to install development tools.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

After installation, add Homebrew to your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Install Git

```bash
brew install git
```

### 3. Install Flutter

```bash
# Install Flutter using Homebrew
brew install --cask flutter

# Verify installation
flutter doctor
```

Address any issues reported by `flutter doctor` before proceeding.

### 4. Install Xcode

1. Download and install Xcode from the Mac App Store
2. Install Xcode command-line tools:

```bash
xcode-select --install
```

3. Accept the Xcode license:

```bash
sudo xcodebuild -license accept
```

4. Configure Xcode for Flutter:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### 5. Install Android Studio

1. Download Android Studio from [developer.android.com](https://developer.android.com/studio)
2. Install Android Studio and open it
3. Go through the setup wizard to install:
   - Android SDK
   - Android SDK Platform-Tools
   - Android SDK Build-Tools
4. Configure Android Studio for Flutter:
   - Install the Flutter and Dart plugins:
     - Open Android Studio
     - Go to Preferences > Plugins
     - Search for "Flutter" and install it (this will also install the Dart plugin)
     - Restart Android Studio

### 6. Install CocoaPods

CocoaPods is required for iOS development:

```bash
sudo gem install cocoapods
```

For M1 Macs, you might need to use:

```bash
sudo arch -x86_64 gem install ffi
sudo arch -x86_64 gem install cocoapods
```

## Project Setup

### 1. Clone the Repository

```bash
git clone https://github.com/dmasubuchi/nikemon.git
cd nikemon
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. iOS Setup

```bash
cd ios
pod install
cd ..
```

If you encounter issues with CocoaPods on M1, try:

```bash
cd ios
arch -x86_64 pod install
cd ..
```

## Google Maps API Configuration

The Nike+ Clone app uses Google Maps for displaying workout routes. You'll need to set up a Google Maps API key:

### 1. Get a Google Maps API Key

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Create an API key in the Credentials section
5. Restrict the API key to only the Maps SDKs for security

### 2. Configure Android

1. Open the file `android/app/src/main/AndroidManifest.xml`
2. Find the `<meta-data>` tag with `android:name="com.google.android.geo.API_KEY"`
3. Replace `android:value="YOUR_API_KEY_HERE"` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY" />
```

### 3. Configure iOS

1. Open the file `ios/Runner/AppDelegate.swift`
2. Verify that it contains:

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

3. Replace `"YOUR_API_KEY_HERE"` with your actual API key

4. Open `ios/Runner/Info.plist` and add:

```xml
<key>GoogleMapsAPIKey</key>
<string>YOUR_ACTUAL_API_KEY</string>
```

5. Also ensure the following permissions are in `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to track your workouts.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background to track your workouts.</string>
```

## Running the Application

### 1. Start an iOS Simulator

```bash
open -a Simulator
```

### 2. Run the App

```bash
flutter run
```

To run on a specific device:

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device_id>
```

## Testing Procedures

### 1. Basic Functionality Testing

1. **Home Screen Navigation**:
   - Verify that the bottom navigation bar works correctly
   - Check that all tabs (Home, Workout, History, Settings) are accessible

2. **Workout Tracking**:
   - Start a new workout
   - Verify that GPS tracking begins
   - Check that distance, pace, and time metrics update in real-time
   - Pause and resume the workout
   - Stop the workout and verify the transition to the Result screen

3. **Result Screen**:
   - Verify that all workout metrics are displayed correctly
   - Check that the route map shows the correct path
   - Test the save functionality
   - Verify navigation back to the Home screen

4. **History Screen**:
   - Check that saved workouts appear in the list
   - Verify that workouts are sorted by date (newest first)
   - Test tapping on a workout to view details
   - Try deleting a workout

5. **Settings Screen**:
   - Toggle debug mode on/off
   - Test the clear history functionality

### 2. Location Permission Testing

1. Deny location permissions when prompted
2. Verify that appropriate error messages are shown
3. Grant permissions and verify that the app works correctly

### 3. Map Display Testing

1. Complete a workout with GPS tracking
2. Verify that the route is displayed correctly on the map
3. Check that start and end markers are positioned correctly

## Troubleshooting

### Common Issues and Solutions

#### Flutter Installation Issues

**Problem**: Flutter doctor shows issues with Xcode or Android Studio.  
**Solution**: Make sure you've completed all the setup steps for each tool and accepted all licenses.

```bash
flutter doctor --android-licenses
sudo xcodebuild -license accept
```

#### CocoaPods Issues on M1

**Problem**: `pod install` fails with architecture-related errors.  
**Solution**: Use the architecture flag:

```bash
arch -x86_64 pod install
```

#### Google Maps Not Displaying

**Problem**: Map shows a gray screen or error message.  
**Solution**: 
1. Verify your API key is correctly set in both Android and iOS configurations
2. Ensure the Google Maps APIs are enabled in your Google Cloud Console
3. Check that the API key has the correct restrictions

#### Location Tracking Issues

**Problem**: App doesn't track location or shows inaccurate data.  
**Solution**:
1. Verify location permissions are granted
2. Check that Location Services are enabled on your device
3. For iOS simulators, you can simulate location:
   - In the simulator, go to Features > Location > Custom Location
   - Enter coordinates and the simulator will use them

#### Build Errors

**Problem**: App fails to build with package-related errors.  
**Solution**: Try cleaning the project and getting dependencies again:

```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

For additional help or to report issues, please create an issue on the [GitHub repository](https://github.com/dmasubuchi/nikemon).
