# Flutter 应用打包指南

## 📱 Android 打包

### 前置要求
- Android SDK
- Java JDK 17+
- Android Studio 或 Android 命令行工具

### 构建 APK

```bash
# 进入项目目录
cd mobile_app

# 构建调试版 APK
flutter build apk --debug

# 构建发布版 APK
flutter build apk --release

# 构建 App Bundle (推荐用于 Google Play)
flutter build appbundle --release
```

### 输出位置
- **调试版 APK**: `build/app/outputs/flutter-apk/app-debug.apk`
- **发布版 APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

### 应用信息
- **包名**: `com.mobileapp.mobile_app`
- **版本**: `1.0.0`
- **版本号**: `1`

### 修改包名
编辑 `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    applicationId = "your.package.name"  // 修改这里
    // ...
}
```

## 🍎 iOS 打包

### 前置要求
- macOS 系统
- Xcode 14.0+
- CocoaPods
- iOS 部署目标 iOS 12.0+

### 构建 IPA

```bash
# 进入项目目录
cd mobile_app

# 安装依赖
cd ios
pod install
cd ..

# 构建调试版
flutter build ios --debug

# 构建发布版
flutter build ios --release

# 打包为 IPA (需要 Xcode)
open ios/Runner.xcworkspace
# 在 Xcode 中: Product > Archive > Distribute App
```

### 输出位置
- **模拟器构建**: `build/ios/iphoneos/Runner.app`
- **真机构建**: `build/ios/iphoneos/Runner.app`
- **IPA 文件**: 通过 Xcode Archive 导出

### 应用信息
- **Bundle ID**: `com.mobileapp.mobileApp`
- **版本**: `1.0.0`
- **构建号**: `1`

### 修改 Bundle ID
1. 打开 `ios/Runner.xcworkspace`
2. 选择 Runner target
3. 在 General 标签中修改 Bundle Identifier

## 🌐 Web 打包

### 构建 Web

```bash
# 进入项目目录
cd mobile_app

# 构建 Web
flutter build web
```

### 输出位置
- **构建目录**: `build/web/`
- **主文件**: `build/web/index.html`

### 部署选项
- **Vercel**: `vercel deploy build/web`
- **Netlify**: `netlify deploy --dir=build/web`
- **GitHub Pages**: 推送到 gh-pages 分支
- **Firebase Hosting**: `firebase deploy`

## 🪟 Windows 打包

### 前置要求
- Windows 10/11
- Visual Studio 2022 (C++ 桌面开发)
- Windows SDK
- **开发者模式**已启用

### 启用开发者模式
```powershell
# 打开开发者模式设置
start ms-settings:developers
```

### 构建 Windows

```bash
# 进入项目目录
cd mobile_app

# 构建 Windows
flutter build windows --release
```

### 输出位置
- **可执行文件**: `build/windows/x64/runner/Release/mobile_app.exe`

## 📦 多平台构建

### 一次性构建所有平台
```bash
# 构建 Web
flutter build web

# 构建 Windows (需要开发者模式)
flutter build windows

# 构建 Android (需要 Android SDK)
flutter build apk

# 构建 iOS (需要 macOS)
flutter build ios
```

## 🔧 签名配置

### Android 签名
1. 创建 keystore 文件
2. 配置 `android/key.properties`
3. 更新 `android/app/build.gradle.kts`

### iOS 签名
1. 在 Apple Developer 创建证书
2. 在 Xcode 中配置签名
3. 选择 Provisioning Profile

## 📋 当前项目配置

### 应用信息
- **应用名称**: Mobile App
- **版本**: 1.0.0
- **Android 包名**: com.mobileapp.mobile_app
- **iOS Bundle ID**: com.mobileapp.mobileApp

### 已配置平台
- ✅ Web
- ✅ Windows
- ✅ Android
- ✅ iOS

## 🚀 快速开始

### 本地测试
```bash
# Web
flutter run -d chrome

# Android (需要连接设备或模拟器)
flutter run -d android

# iOS (需要连接设备或模拟器)
flutter run -d ios

# Windows
flutter run -d windows
```

### 构建发布版本
```bash
# Web (已完成 ✅)
flutter build web

# Android (需要 Android SDK)
flutter build apk --release

# iOS (需要 macOS + Xcode)
flutter build ios --release

# Windows (需要开发者模式)
flutter build windows --release
```

## 📝 注意事项

1. **Windows 环境**: 无法直接构建 Android 和 iOS，需要对应平台环境
2. **开发者模式**: Windows 构建需要启用开发者模式
3. **签名**: 发布版本需要配置签名
4. **权限**: 部分功能需要平台权限（相机、存储等）
5. **依赖**: 确保所有依赖已正确安装

## 🎯 推荐部署方案

### Web
- **Vercel**: 免费且快速
- **Netlify**: 免费且简单
- **Firebase Hosting**: Google 生态集成

### Android
- **Google Play**: 主要应用商店
- **APK 直链**: 网站直接下载

### iOS
- **App Store**: 唯一官方渠道
- **TestFlight**: 内测平台

### Windows
- **Microsoft Store**: 官方应用商店
- **直接分发**: 提供安装包下载
