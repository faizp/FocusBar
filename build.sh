#!/bin/bash
set -e

APP_NAME="FocusBar"
BUILD_DIR=".build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "Building $APP_NAME..."
swift build -c release 2>&1

echo "Creating app bundle..."
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS" "$RESOURCES"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS/$APP_NAME"

# Copy resource bundle if it exists
RESOURCE_BUNDLE="$BUILD_DIR/${APP_NAME}_${APP_NAME}.bundle"
if [ -d "$RESOURCE_BUNDLE" ]; then
    cp -R "$RESOURCE_BUNDLE" "$RESOURCES/"
fi

# Create Info.plist
cat > "$CONTENTS/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>FocusBar</string>
    <key>CFBundleIdentifier</key>
    <string>com.focusbar.app</string>
    <key>CFBundleName</key>
    <string>FocusBar</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
</dict>
</plist>
PLIST

echo "App bundle created at $APP_BUNDLE"

# Handle command: install or dmg
case "${1:-}" in
    install)
        echo "Installing to /Applications..."
        rm -rf "/Applications/$APP_BUNDLE"
        cp -R "$APP_BUNDLE" "/Applications/$APP_BUNDLE"
        echo "Installed! Open from Spotlight or run: open /Applications/$APP_BUNDLE"
        ;;
    dmg)
        DMG_NAME="$APP_NAME.dmg"
        DMG_TEMP="dmg_temp"
        rm -rf "$DMG_TEMP" "$DMG_NAME"
        mkdir -p "$DMG_TEMP"
        cp -R "$APP_BUNDLE" "$DMG_TEMP/"
        ln -s /Applications "$DMG_TEMP/Applications"
        hdiutil create -volname "$APP_NAME" -srcfolder "$DMG_TEMP" -ov -format UDZO "$DMG_NAME"
        rm -rf "$DMG_TEMP"
        echo "DMG created at $DMG_NAME"
        ;;
    *)
        echo "Run with: open $APP_BUNDLE"
        echo ""
        echo "Commands:"
        echo "  ./build.sh install   - Install to /Applications (Spotlight & Launchpad)"
        echo "  ./build.sh dmg       - Create a distributable DMG"
        ;;
esac
