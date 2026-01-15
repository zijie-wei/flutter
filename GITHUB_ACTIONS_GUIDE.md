# 使用 GitHub Actions 构建 APK

## 🚀 快速开始

### 步骤 1: 推送代码到 GitHub

如果您还没有 GitHub 仓库：

```bash
# 初始化 Git 仓库
cd f:\ceshi011\mobile_app
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit"

# 创建 GitHub 仓库后，添加远程仓库
git remote add origin https://github.com/your-username/your-repo.git

# 推送到 GitHub
git branch -M main
git push -u origin main
```

### 步骤 2: 触发构建

有两种方式触发构建：

#### 方式 1: 通过推送代码（自动触发）
```bash
# 任何推送到 main 或 master 分支都会自动触发构建
git push origin main
```

#### 方式 2: 手动触发
1. 访问您的 GitHub 仓库
2. 点击 "Actions" 标签
3. 选择 "Build Android APK" workflow
4. 点击 "Run workflow" 按钮
5. 点击 "Run workflow" 确认

### 步骤 3: 下载 APK

构建完成后：

1. 访问 GitHub 仓库的 "Actions" 标签
2. 点击最新的构建记录
3. 滚动到页面底部
4. 在 "Artifacts" 部分下载：
   - `app-release-apk` - 发布版 APK（用于生产）
   - `app-debug-apk` - 调试版 APK（用于测试）

## 📋 Workflow 配置说明

### 构建配置

```yaml
name: Build Android APK

on:
  workflow_dispatch:  # 手动触发
  push:            # 代码推送时自动触发
  pull_request:    # Pull Request 时自动触发

jobs:
  build:
    runs-on: ubuntu-latest  # 使用 Ubuntu 环境
    steps:
      - 检出代码
      - 设置 Flutter 环境
      - 获取依赖
      - 构建 APK
      - 上传构建产物
```

### 支持的触发方式

1. **手动触发** - 在 GitHub Actions 页面点击 "Run workflow"
2. **自动触发** - 推送代码到 main 或 master 分支
3. **PR 触发** - 创建或更新 Pull Request

## 📱 APK 信息

### 发布版 APK
- **文件名**: app-release.apk
- **用途**: 生产环境，分发给用户
- **大小**: 约 20-50 MB
- **优化**: 已优化，体积最小

### 调试版 APK
- **文件名**: app-debug.apk
- **用途**: 开发测试，调试问题
- **大小**: 约 25-60 MB
- **优化**: 包含调试信息，体积较大

## 🎯 使用场景

### 场景 1: 日常开发
```bash
# 1. 修改代码
# 2. 提交代码
git add .
git commit -m "Update feature"

# 3. 推送到 GitHub
git push origin main

# 4. 等待 GitHub Actions 自动构建
# 5. 下载 APK 测试
```

### 场景 2: 发布新版本
```bash
# 1. 更新版本号
# 编辑 pubspec.yaml
# version: 1.0.0 -> 1.0.1

# 2. 提交并推送
git add pubspec.yaml
git commit -m "Release v1.0.1"
git push origin main

# 3. 等待构建完成
# 4. 下载发布版 APK
# 5. 分发给用户
```

### 场景 3: 快速测试
```bash
# 1. 在 GitHub Actions 页面手动触发构建
# 2. 下载调试版 APK
# 3. 在设备上测试
```

## 🔧 自定义构建配置

### 修改 Flutter 版本

编辑 `.github/workflows/build-apk.yml`:

```yaml
- name: Set up Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.38.7'  # 修改这里
    channel: 'stable'
```

### 修改构建类型

默认构建两种类型（发布版和调试版）。如果只需要一种：

```yaml
# 只构建发布版
- name: Build APK (Release)
  run: flutter build apk --release

- name: Upload APK
  uses: actions/upload-artifact@v4
  with:
    name: app-release-apk
    path: build/app/outputs/flutter-apk/app-release.apk
```

### 添加签名配置

如果要签名 APK，需要：

1. 在 GitHub Secrets 中添加签名密钥
2. 修改 workflow 配置

```yaml
- name: Sign APK
  run: |
    echo "${{ secrets.KEYSTORE_PASSWORD }}" | keytool -importkeystore -srckeystore keystore.jks -destkeystore signed-keystore.jks -srcstorepass changeit -deststorepass changeit
    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore signed-keystore.jks -storepass "${{ secrets.KEYSTORE_PASSWORD }}" -keypass "${{ secrets.KEY_PASSWORD }}" build/app/outputs/flutter-apk/app-release.apk "${{ secrets.KEY_ALIAS }}"
```

## 📊 构建时间

### 预计时间
- **代码检出**: 30 秒
- **设置 Flutter**: 2-3 分钟
- **获取依赖**: 1-2 分钟
- **构建 APK**: 3-5 分钟
- **上传产物**: 30 秒

**总计**: 约 7-11 分钟

### 影响因素
- 网络速度（下载 Flutter）
- 依赖数量
- 代码复杂度
- GitHub Actions 负载

## 🎯 最佳实践

### 1. 版本管理
```bash
# 使用语义化版本
# 1.0.0 -> 1.0.1 (bug fix)
# 1.0.0 -> 1.1.0 (new feature)
# 1.0.0 -> 2.0.0 (breaking change)
```

### 2. 分支策略
```bash
# main/master - 生产分支
# develop - 开发分支
# feature/* - 功能分支
# hotfix/* - 紧急修复分支
```

### 3. 提交信息
```bash
# 使用清晰的提交信息
git commit -m "feat: add user login feature"
git commit -m "fix: resolve payment issue"
git commit -m "docs: update README"
```

## 📞 故障排除

### 问题 1: 构建失败

**可能原因**:
- 代码有错误
- 依赖冲突
- Flutter 版本不兼容

**解决方案**:
1. 检查构建日志
2. 在本地运行 `flutter analyze`
3. 修复问题后重新推送

### 问题 2: APK 无法安装

**可能原因**:
- 签名问题
- 权限问题
- 版本不兼容

**解决方案**:
1. 使用调试版 APK 测试
2. 检查 Android 版本兼容性
3. 查看设备日志

### 问题 3: 构建时间过长

**可能原因**:
- 首次构建（需要缓存）
- 依赖过多
- 网络慢

**解决方案**:
1. 等待首次构建完成（后续会更快）
2. 启用缓存（已配置）
3. 使用更快的构建环境

## 🚀 部署 APK

### 方式 1: 直接下载链接

GitHub Actions 构建完成后，APK 文件会保留30天，可以直接下载分享。

### 方式 2: 自动发布到 Release

可以配置自动发布到 GitHub Releases：

```yaml
- name: Create Release
  uses: softprops/action-gh-release@v1
  with:
    files: build/app/outputs/flutter-apk/app-release.apk
    draft: false
    prerelease: false
```

### 方式 3: 集成应用商店

可以配置自动上传到：
- Google Play Store
- 华为应用市场
- 小米应用商店

## 📋 总结

### 优势
- ✅ 完全自动化
- ✅ 不需要本地 Android SDK
- ✅ 构建历史可追溯
- ✅ 支持多种触发方式
- ✅ 免费使用

### 使用流程
1. 推送代码到 GitHub
2. 等待 GitHub Actions 构建
3. 下载生成的 APK
4. 测试和分发

### 下一步
1. 创建 GitHub 仓库
2. 推送代码
3. 触发构建
4. 下载 APK

---

**详细说明请查看：.github/workflows/build-apk.yml** 🚀
