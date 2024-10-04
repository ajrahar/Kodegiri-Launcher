# Kodegiri Web Launcher
**Welcome to the fully customizable CRM mobile app!**  
This app is designed to meet your business needs by providing direct access to your personalized CRM. Each client has their own unique domain, individual user credentials, and a security token to ensure safe access to the CRM.

### Pre-Configuration Process:

1. **CRM URL Input** - Enter your CRM's URL.
2. **Token Input** - Input your unique security token.
3. **Authorize Button** - Once everything is set, click **Authorize** to unlock your CRM and start managing your business efficiently.

This system ensures both security and personalization. One app for many clients, but delivering an exclusive experience tailored just for you.

---

## Prerequisites

Before you start, ensure you have the following installed:

- **Flutter SDK**: Install the latest stable version of Flutter from the [Flutter website](https://flutter.dev).
- **Dart SDK**: Included with the Flutter SDK.
- **Android Studio or VS Code**: These IDEs offer great support for Flutter development.
- **Git**: Necessary for cloning the repository.

---

## Getting Started

### Step 1: Clone the Repository

1. Open your terminal or command prompt.
2. Navigate to the directory where you want to clone the repository.
3. Run the following command:

```bash
git clone https://github.com/ajrahar/Kodegiri-Launcher.git
```

### Step 2: Open and Prepare the Project

1. Open the project in your preferred IDE (Android Studio or VS Code).
2. In the terminal of your IDE, run the following command to fetch all the necessary packages:

```bash
flutter pub get
```

If the project includes native code or specific platform-dependent features, ensure the corresponding development tools (e.g., Xcode for iOS, Android SDK for Android) are set up correctly.

### Step 3: Check for Gradle Issues

For Android projects, Flutter uses **Gradle** to manage dependencies and build settings.

1. Navigate to the `android/` directory within your project folder.
2. Ensure the `gradle-wrapper.properties` file points to a valid Gradle distribution URL suitable for your project.
3. Review the `build.gradle` files (both project-level and app-level) for potential issues, such as:
   - Outdated dependencies
   - SDK version conflicts
   - Plugin version incompatibilities

### Step 4: Run the App

1. Connect a physical device or set up an emulator.
2. Run the following command to check if everything is set up correctly:

```bash
flutter doctor
```

3. Once ready, run the app with:

```bash
flutter run
```

---

## Troubleshooting Common Issues

### 1. Dependency Conflicts

- **Problem**: Errors related to outdated or incompatible dependencies.
- **Solution**: Update them in your `pubspec.yaml` file and run `flutter pub get` again.

### 2. Gradle Errors

- **Problem**: Common issues include Gradle sync failures or plugins requiring a newer version of Gradle.
- **Solution**: Update the `gradle-wrapper.properties` file to use the correct Gradle version:

```bash
distributionUrl=https\://services.gradle.org/distributions/gradle-6.7-all.zip
```

Also, ensure the Android Gradle Plugin (AGP) in `android/build.gradle` is up-to-date:

```bash
classpath 'com.android.tools.build:gradle:4.1.0'
```

### 3. iOS Setup with CocoaPods

For iOS, Flutter uses **CocoaPods** to manage dependencies.

- **Installation**: If not already installed, run:

```bash
sudo gem install cocoapods
```

- **Common Error**: CocoaPods repository out of date or `Podfile.lock` out of sync with `Podfile`.
- **Solution**: Navigate to the `ios/` directory and run:

```bash
pod install
```

If issues persist, update the repository first:

```bash
pod repo update
pod install
```

---

## Common Issues and Solutions

### SDK Version Conflicts

- **Problem**: Build failures due to mismatched SDK versions.
- **Solution**: Update the `compileSdkVersion` and `targetSdkVersion` in `android/app/build.gradle` to match the latest supported SDKs.

### Plugin Compatibility

- **Problem**: Plugins fail due to incompatibilities with project setup.
- **Solution**: Ensure plugins listed in `pubspec.yaml` are updated and compatible. Refer to the plugin's official documentation for compatibility notes.

---

## Kotlin and Gradle Versions

### Kotlin Version

- **Problem**: Kotlin version specified in `build.gradle` is not compatible with the Kotlin plugin or project dependencies.
- **Solution**: Update the Kotlin version in `android/build.gradle`:

```gradle
ext.kotlin_version = '1.X.X'
dependencies {
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
}
```

### Gradle Version

- **Problem**: Gradle sync or plugin failures.
- **Solution**: Ensure the `gradle-wrapper.properties` file uses the correct Gradle version:

```bash
distributionUrl=https\://services.gradle.org/distributions/gradle-6.7-all.zip
```

---
