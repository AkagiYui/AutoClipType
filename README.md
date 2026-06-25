# AutoClipType

AutoClipType 是一个 macOS 菜单栏工具，用来把本机剪贴板里的文本模拟成逐字键盘输入。它适合 VNC、远程桌面等不支持剪贴板共享或剪贴板同步不可靠的场景。

## 功能

- 菜单栏常驻，不显示 Dock 图标
- 可通过菜单项或全局热键触发输入
- 默认热键：Control + Option + V
- 输入过程中再次按热键可停止
- 字符间延迟可设置为 0.1 到 5 秒，默认 0.1 秒
- 开始前延迟可设置为 0 到 5 秒
- 换行模拟为 Enter
- 使用 `CGEventKeyboardSetUnicodeString` 发送 Unicode 字符，支持中文和常见 Unicode 文本
- 重要错误才请求并发送系统通知，例如缺少辅助功能权限或剪贴板没有文本
- 设置页显示辅助功能权限状态，并可跳转系统设置
- 支持用户明确开启的登录后自动启动，默认关闭
- 支持英文和简体中文，默认跟随系统语言
- 支持浅色和深色外观，默认跟随系统主题
- 保留 App Sandbox，面向 Mac App Store 分发

## 隐私

AutoClipType 纯本地运行。它只会在你主动点击菜单或按下热键时读取当前剪贴板文本，不监听剪贴板变化，不保存剪贴板历史，不上传任何内容，也不需要网络功能。

## 权限

macOS 要求模拟键盘输入的 app 获得辅助功能权限。

首次使用前，请打开：系统设置 > 隐私与安全性 > 辅助功能，然后允许 AutoClipType。

设置窗口中也会显示当前辅助功能权限状态，并提供打开系统设置的按钮。

## Developer ID 签名与公证

给同事分发不经过 Mac App Store 的版本时，建议使用 Developer ID 签名并完成 Apple 公证。这样对方从浏览器、聊天工具或 AirDrop 收到 app 后，通常不需要再执行 `xattr -c`。

第一次使用 `notarytool` 前，先把公证凭据保存到本机钥匙串。这里的密码不是 Apple ID 登录密码，而是 Apple ID 的 app-specific password。

```sh
xcrun notarytool store-credentials "AutoClipType-notary" \
	--apple-id "你的 Apple ID 邮箱" \
	--team-id "4M56H5UB5R" \
	--password "xxxx-xxxx-xxxx-xxxx"
```

保存好凭据后，可以从仓库根目录执行下面的命令。这个流程会从代码编译归档开始，导出 Developer ID 版本，提交公证，把公证票据 stapler 到 `.app`，最后生成可发给同事的 zip。

```sh
zsh <<'EOF'
set -euo pipefail

# 工程和签名配置；TEAM_ID 来自 Xcode 工程里的 DEVELOPMENT_TEAM。
PROJECT="AutoClipType.xcodeproj"
SCHEME="AutoClipType"
TEAM_ID="4M56H5UB5R"
NOTARY_PROFILE="AutoClipType-notary"

# 所有中间产物都放在 build/developer-id，方便反复测试时清理。
BUILD_ROOT="$PWD/build/developer-id"
ARCHIVE_PATH="$BUILD_ROOT/AutoClipType.xcarchive"
EXPORT_DIR="$BUILD_ROOT/export"
EXPORT_OPTIONS_PLIST="$BUILD_ROOT/ExportOptions.plist"
APP_PATH="$EXPORT_DIR/AutoClipType.app"
NOTARY_ZIP="$BUILD_ROOT/AutoClipType-for-notary.zip"
FINAL_ZIP="$BUILD_ROOT/AutoClipType-notarized.zip"

rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT" "$EXPORT_DIR"

# 1. 从源码编译 Release，并生成 Xcode archive。
xcodebuild archive \
	-project "$PROJECT" \
	-scheme "$SCHEME" \
	-configuration Release \
	-destination 'generic/platform=macOS' \
	-archivePath "$ARCHIVE_PATH" \
	-allowProvisioningUpdates

# 2. 生成导出配置：method=developer-id 会让 Xcode 导出 Developer ID 分发版本。
cat > "$EXPORT_OPTIONS_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>destination</key>
	<string>export</string>
	<key>method</key>
	<string>developer-id</string>
	<key>signingStyle</key>
	<string>automatic</string>
	<key>teamID</key>
	<string>$TEAM_ID</string>
	<key>stripSwiftSymbols</key>
	<true/>
</dict>
</plist>
PLIST

# 3. 从 archive 导出真正要分发的 .app。
xcodebuild -exportArchive \
	-archivePath "$ARCHIVE_PATH" \
	-exportPath "$EXPORT_DIR" \
	-exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
	-allowProvisioningUpdates

# 4. 本地先检查签名；这里通过后再提交公证，失败时更容易定位问题。
codesign --verify --deep --strict --verbose=2 "$APP_PATH"
codesign -dv --verbose=4 "$APP_PATH"

# 5. 公证只能提交 zip、dmg 或 pkg，不能直接提交 .app；ditto 会保留 macOS bundle 需要的元数据。
ditto -c -k --keepParent "$APP_PATH" "$NOTARY_ZIP"

# 6. 提交 Apple 公证并等待结果。Accepted 后才继续；失败时按输出里的 submission id 查看日志。
xcrun notarytool submit "$NOTARY_ZIP" \
	--keychain-profile "$NOTARY_PROFILE" \
	--wait

# 7. 把公证票据 stapler 到 .app，这样离线打开也能通过 Gatekeeper 检查。
xcrun stapler staple "$APP_PATH"
xcrun stapler validate "$APP_PATH"

# 8. 用 Gatekeeper 规则做一次本机验证；理想输出包含 accepted 和 Notarized Developer ID。
spctl -a -vv --type execute "$APP_PATH"

# 9. stapler 之后重新打包，发给同事的是这个最终 zip。
ditto -c -k --keepParent "$APP_PATH" "$FINAL_ZIP"

echo "完成：$FINAL_ZIP"
EOF
```

如果 `notarytool submit` 返回失败，可以用输出里的 submission id 查看原因：

```sh
xcrun notarytool log "submission-id" --keychain-profile "AutoClipType-notary"
```

### 打包为 DMG

如果把 `.dmg` 作为最终分发物，建议也对 DMG 提交公证并 stapler。下面的命令会把已经导出的 `build/developer-id/export/AutoClipType.app` 打包成 DMG，窗口里包含 AutoClipType.app、Applications 快捷方式，以及一张指引用户拖拽安装的背景图。

先安装 `create-dmg`：

```sh
brew install create-dmg
```

然后执行：

```sh
zsh <<'EOF'
set -euo pipefail

# 这里使用前面 Developer ID 流程导出的 app；它应该已经完成签名、公证和 stapler。
APP="build/developer-id/export/AutoClipType.app"
NOTARY_PROFILE="AutoClipType-notary"

# DMG 相关产物统一放在 build/developer-id/dmg，最终 DMG 放在 build/developer-id。
DMG_ROOT="$PWD/build/developer-id/dmg"
SOURCE_DIR="$DMG_ROOT/source"
BACKGROUND="$DMG_ROOT/background.png"
FINAL_DMG="$PWD/build/developer-id/AutoClipType-notarized.dmg"

if [ ! -d "$APP" ]; then
	echo "找不到 app：$APP" >&2
	echo "请先执行前面的 Developer ID 签名与公证流程。" >&2
	exit 1
fi

# 1. 先确认 app 本身已经通过签名、公证和 Gatekeeper 检查。
xcrun stapler validate "$APP"
spctl -a -vv --type execute "$APP"
codesign --verify --deep --strict --verbose=2 "$APP"

# 2. 准备 DMG 源目录。只放 app，Applications 快捷方式由 create-dmg 生成。
rm -rf "$DMG_ROOT"
mkdir -p "$SOURCE_DIR"
ditto "$APP" "$SOURCE_DIR/AutoClipType.app"

# 3. 生成 DMG 背景图。背景图只是临时产物，不需要提交到仓库。
swift -e 'import AppKit; let output = CommandLine.arguments[1]; let size = NSSize(width: 640, height: 400); let image = NSImage(size: size); image.lockFocus(); NSColor(calibratedRed: 0.965, green: 0.976, blue: 0.992, alpha: 1).setFill(); NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill(); let title = "Install AutoClipType" as NSString; let subtitle = "Drag the app into Applications" as NSString; let titleAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 30, weight: .semibold), .foregroundColor: NSColor(calibratedRed: 0.07, green: 0.11, blue: 0.18, alpha: 1)]; let subtitleAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 17, weight: .regular), .foregroundColor: NSColor(calibratedRed: 0.24, green: 0.30, blue: 0.40, alpha: 1)]; title.draw(at: NSPoint(x: 42, y: 323), withAttributes: titleAttrs); subtitle.draw(at: NSPoint(x: 42, y: 294), withAttributes: subtitleAttrs); let path = NSBezierPath(); path.move(to: NSPoint(x: 265, y: 190)); path.line(to: NSPoint(x: 374, y: 190)); path.lineWidth = 7; NSColor(calibratedRed: 0.14, green: 0.45, blue: 0.86, alpha: 1).setStroke(); path.stroke(); let arrow = NSBezierPath(); arrow.move(to: NSPoint(x: 374, y: 190)); arrow.line(to: NSPoint(x: 348, y: 207)); arrow.move(to: NSPoint(x: 374, y: 190)); arrow.line(to: NSPoint(x: 348, y: 173)); arrow.lineWidth = 7; arrow.stroke(); let left = "AutoClipType" as NSString; let right = "Applications" as NSString; let labelAttrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 15, weight: .medium), .foregroundColor: NSColor(calibratedRed: 0.13, green: 0.18, blue: 0.27, alpha: 1)]; left.draw(at: NSPoint(x: 104, y: 77), withAttributes: labelAttrs); right.draw(at: NSPoint(x: 439, y: 77), withAttributes: labelAttrs); image.unlockFocus(); guard let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff), let data = bitmap.representation(using: .png, properties: [:]) else { fatalError("failed to render background") }; try data.write(to: URL(fileURLWithPath: output))' "$BACKGROUND"

# 4. 生成带背景、app 图标和 Applications 快捷方式的 DMG。
# 如果本机钥匙串里有 Developer ID Application 证书，也可以额外给 create-dmg 加：
#   --codesign "Developer ID Application: 你的名字 (TEAMID)" \
rm -f "$FINAL_DMG"
create-dmg \
	--volname "AutoClipType" \
	--background "$BACKGROUND" \
	--window-size 640 400 \
	--text-size 12 \
	--icon-size 96 \
	--icon "AutoClipType.app" 155 205 \
	--hide-extension "AutoClipType.app" \
	--app-drop-link 485 205 \
	--no-internet-enable \
	"$FINAL_DMG" \
	"$SOURCE_DIR"

# 5. 把 DMG 作为最终分发物提交公证，并把票据 stapler 到 DMG。
xcrun notarytool submit "$FINAL_DMG" \
	--keychain-profile "$NOTARY_PROFILE" \
	--wait
xcrun stapler staple "$FINAL_DMG"
xcrun stapler validate "$FINAL_DMG"

# 6. 验证 DMG 完整性，再挂载检查里面是否包含 app 和 Applications 快捷方式。
hdiutil verify "$FINAL_DMG"
MOUNT_INFO="$(mktemp)"
hdiutil attach "$FINAL_DMG" -nobrowse -readonly > "$MOUNT_INFO"
VOLUME="$(awk '/\/Volumes\// {print $3; exit}' "$MOUNT_INFO")"
find "$VOLUME" -maxdepth 2 -print
hdiutil detach "$VOLUME"
rm -f "$MOUNT_INFO"

echo "完成：$FINAL_DMG"
EOF
```

### 打包为 PKG

如果某些分发渠道会把 `.zip` 或 `.dmg` 标记为由沙盒 App 创建，导致最终 `.app` 无法打开，可以尝试改用 `.pkg` 安装包。PKG 会通过 macOS Installer 把 app 安装到 `/Applications`，更接近企业内部分发的安装流程。

正式分发的 PKG 需要 `Developer ID Installer` 证书，不是 `Developer ID Application` 证书。可以先在 Xcode 的 `Settings > Accounts > Manage Certificates...` 里新建 `Developer ID Installer`，然后用下面命令确认：

```sh
security find-identity -v | grep "Developer ID Installer"
```

生成、签名、公证并验证 PKG：

```sh
zsh <<'EOF'
set -euo pipefail

APP="build/developer-id/export/AutoClipType.app"
INSTALLER_SIGN_ID="Developer ID Installer: 你的名字 (TEAMID)"
NOTARY_PROFILE="AutoClipType-notary"

PKG_ROOT="$PWD/build/developer-id/pkg"
INSTALL_ROOT="$PKG_ROOT/root"
COMPONENT_PKG="$PKG_ROOT/AutoClipType-component.pkg"
FINAL_PKG="$PWD/build/developer-id/AutoClipType.pkg"

if [ ! -d "$APP" ]; then
	echo "找不到 app：$APP" >&2
	echo "请先执行 Developer ID 签名与公证流程。" >&2
	exit 1
fi

# 1. 确认要安装进 PKG 的 app 本身已经通过签名、公证和 Gatekeeper 检查。
xcrun stapler validate "$APP"
spctl -a -vv --type execute "$APP"

# 2. 构造安装根目录。安装时会把 AutoClipType.app 放到 /Applications。
rm -rf "$PKG_ROOT"
mkdir -p "$INSTALL_ROOT/Applications"
ditto "$APP" "$INSTALL_ROOT/Applications/AutoClipType.app"

# 3. 生成组件包。
pkgbuild \
	--root "$INSTALL_ROOT" \
	--identifier com.akagiyui.AutoClipType.pkg \
	--version 1.0 \
	--install-location / \
	"$COMPONENT_PKG"

# 4. 生成最终产品包，并使用 Developer ID Installer 证书签名。
productbuild \
	--package "$COMPONENT_PKG" \
	--sign "$INSTALLER_SIGN_ID" \
	"$FINAL_PKG"

# 5. 公证 PKG，并把公证票据 stapler 到 PKG。
xcrun notarytool submit "$FINAL_PKG" \
	--keychain-profile "$NOTARY_PROFILE" \
	--wait
xcrun stapler staple "$FINAL_PKG"
xcrun stapler validate "$FINAL_PKG"

# 6. 验证 PKG 签名和 Gatekeeper 安装判定。
pkgutil --check-signature "$FINAL_PKG"
spctl -a -vv --type install "$FINAL_PKG"

echo "完成：$FINAL_PKG"
EOF
```