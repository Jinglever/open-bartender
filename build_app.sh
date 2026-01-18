#!/bin/bash

# Build the generic executable
# Note: Requires a matching Swift Toolchain and SDK
swift build -c release

# Create the App Bundle Structure
APP_NAME="OpenBartender"
BUNDLE_PATH=".build/release/$APP_NAME.app"
mkdir -p "$BUNDLE_PATH/Contents/MacOS"
mkdir -p "$BUNDLE_PATH/Contents/Resources"

# Copy Executable
cp ".build/release/$APP_NAME" "$BUNDLE_PATH/Contents/MacOS/$APP_NAME"

# Copy Info.plist
cp "Sources/App/Info.plist" "$BUNDLE_PATH/Contents/Info.plist"

# Clean up PkgInfo
echo "APPL????" > "$BUNDLE_PATH/Contents/PkgInfo"

echo "App Bundle created at: $BUNDLE_PATH"
echo "You can move this to /Applications to run it."
