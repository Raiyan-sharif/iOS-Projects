#!/bin/bash

# Script to build and prepare Convay iOS SDK for local testing
# Usage: ./build-local-sdk.sh [version-override]

set -e -u

THIS_DIR=$(cd -P "$(dirname "$(readlink "${BASH_SOURCE[0]}" || echo "${BASH_SOURCE[0]}")")" && pwd)
IOS_DIR="${THIS_DIR}"
PROJECT_ROOT="${THIS_DIR}/.."
LOCAL_SDK_DIR="${PROJECT_ROOT}/local-ios-sdk"
LOCAL_SDK_PATH=$(cd "${PROJECT_ROOT}" && pwd)/local-ios-sdk

# Get SDK version from Info.plist or use override
DEFAULT_SDK_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${THIS_DIR}/sdk/src/Info.plist)
SDK_VERSION=${OVERRIDE_SDK_VERSION:-${1:-${DEFAULT_SDK_VERSION}}}

echo "=========================================="
echo "Building Convay iOS SDK for Local Testing"
echo "=========================================="
echo "SDK Version: ${SDK_VERSION}"
echo "Local SDK Directory: ${LOCAL_SDK_PATH}"
echo "=========================================="
echo ""

# Check if SDK version already exists
if [[ -d "${LOCAL_SDK_PATH}/ConvayMeetSDK.xcframework" ]]; then
    echo "⚠️  WARNING: SDK already exists in local directory!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Build cancelled."
        exit 1
    fi
    echo "Proceeding with overwrite..."
fi

# Change to project root
pushd "${PROJECT_ROOT}" > /dev/null

# Ensure CocoaPods dependencies are installed
echo ""
echo "Step 0: Checking CocoaPods dependencies..."
if ! command -v pod &> /dev/null; then
    echo "⚠️  ERROR: CocoaPods is not installed. Please install it with:"
    echo "   sudo gem install cocoapods"
    exit 1
fi

if [[ ! -d "${THIS_DIR}/Pods" ]] || [[ ! -f "${THIS_DIR}/Podfile.lock" ]]; then
    echo "Installing CocoaPods dependencies..."
    cd "${THIS_DIR}"
    pod install
    cd "${PROJECT_ROOT}"
else
    echo "CocoaPods dependencies already installed."
fi

# Clean previous builds
echo ""
echo "Step 1: Cleaning previous builds..."
rm -rf ios/sdk/out
rm -rf "${LOCAL_SDK_PATH}"

# Create symbolic links for Lato fonts if they don't exist (needed for app target dependency)
echo ""
echo "Step 1.5: Setting up font links (for app target dependencies)..."
FONTS_DIR="${PROJECT_ROOT}/node_modules/react-native-vector-icons/Fonts"
mkdir -p "${FONTS_DIR}"
# Link all Lato fonts dynamically
for font_file in "${THIS_DIR}/app/src"/Lato-*.ttf; do
    if [[ -f "${font_file}" ]]; then
        font_name=$(basename "${font_file}")
        if [[ ! -f "${FONTS_DIR}/${font_name}" ]] || [[ -L "${FONTS_DIR}/${font_name}" ]]; then
            ln -sf "${font_file}" "${FONTS_DIR}/${font_name}"
            echo "  Linked ${font_name}"
        fi
    fi
done
# Handle Lato-SemiBold.ttf if it doesn't exist (create symlink to Lato-Bold.ttf as fallback)
if [[ ! -f "${FONTS_DIR}/Lato-SemiBold.ttf" ]]; then
    if [[ -f "${THIS_DIR}/app/src/Lato-Bold.ttf" ]]; then
        ln -sf "${THIS_DIR}/app/src/Lato-Bold.ttf" "${FONTS_DIR}/Lato-SemiBold.ttf"
        echo "  Linked Lato-SemiBold.ttf -> Lato-Bold.ttf (fallback)"
    fi
fi

# Clean Xcode build
echo ""
echo "Step 2: Cleaning Xcode workspace..."
xcodebuild clean \
    -workspace ios/convay-meet.xcworkspace \
    -scheme ConvayMeetSDK

# Build for iOS Simulator
echo ""
echo "Step 3: Building for iOS Simulator..."
xcodebuild archive \
    -workspace ios/convay-meet.xcworkspace \
    -scheme ConvayMeetSDK \
    -configuration Release \
    -sdk iphonesimulator \
    -destination='generic/platform=iOS Simulator' \
    -archivePath ios/sdk/out/ios-simulator \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Build for iOS Device
echo ""
echo "Step 4: Building for iOS Device..."
xcodebuild archive \
    -workspace ios/convay-meet.xcworkspace \
    -scheme ConvayMeetSDK \
    -configuration Release \
    -sdk iphoneos \
    -destination='generic/platform=iOS' \
    -archivePath ios/sdk/out/ios-device \
    SKIP_INSTALL=NO \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Create XCFramework
echo ""
echo "Step 5: Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework ios/sdk/out/ios-device.xcarchive/Products/Library/Frameworks/ConvayMeetSDK.framework \
    -framework ios/sdk/out/ios-simulator.xcarchive/Products/Library/Frameworks/ConvayMeetSDK.framework \
    -output ios/sdk/out/ConvayMeetSDK.xcframework

# Copy required frameworks to a separate directory (NOT embedded to avoid duplicate symbols)
# These frameworks must be added to the consuming app's project
echo ""
echo "Step 5.5: Preparing required framework dependencies..."
DEPENDENCIES_DIR="${LOCAL_SDK_PATH}/RequiredFrameworks"
mkdir -p "${DEPENDENCIES_DIR}"

# Copy GiphyUISDK XCFramework
if [[ -d "${THIS_DIR}/Pods/Giphy/GiphySDK/GiphyUISDK.xcframework" ]]; then
    cp -R "${THIS_DIR}/Pods/Giphy/GiphySDK/GiphyUISDK.xcframework" "${DEPENDENCIES_DIR}/"
    echo "  Copied GiphyUISDK.xcframework"
fi

# Copy WebRTC XCFramework
if [[ -d "${THIS_DIR}/Pods/JitsiWebRTC/WebRTC.xcframework" ]]; then
    cp -R "${THIS_DIR}/Pods/JitsiWebRTC/WebRTC.xcframework" "${DEPENDENCIES_DIR}/"
    echo "  Copied WebRTC.xcframework"
fi

# Note: These frameworks are NOT embedded in ConvayMeetSDK.xcframework to avoid duplicate symbol conflicts
# (e.g., libwebp is included in both ConvayMeetSDK and GiphyUISDK)
# They must be added separately to the consuming app's project

# Create local SDK directory structure
echo ""
echo "Step 6: Preparing local SDK directory..."
mkdir -p "${LOCAL_SDK_PATH}"

# Copy XCFramework to local directory
cp -R ios/sdk/out/ConvayMeetSDK.xcframework "${LOCAL_SDK_PATH}/"

# Copy required Lato fonts to SDK directory
echo ""
echo "Step 6.5: Copying required fonts..."
FONTS_OUT_DIR="${LOCAL_SDK_PATH}/Fonts"
mkdir -p "${FONTS_OUT_DIR}"
for font_file in "${THIS_DIR}/app/src"/Lato-*.ttf; do
    if [[ -f "${font_file}" ]]; then
        cp "${font_file}" "${FONTS_OUT_DIR}/"
        echo "  Copied $(basename "${font_file}")"
    fi
done
# Handle Lato-SemiBold.ttf if it doesn't exist (create symlink to Lato-Bold.ttf)
if [[ ! -f "${THIS_DIR}/app/src/Lato-SemiBold.ttf" ]] && [[ -f "${THIS_DIR}/app/src/Lato-Bold.ttf" ]]; then
    cp "${THIS_DIR}/app/src/Lato-Bold.ttf" "${FONTS_OUT_DIR}/Lato-SemiBold.ttf"
    echo "  Copied Lato-SemiBold.ttf (from Lato-Bold.ttf)"
fi
echo "  Fonts copied to ${FONTS_OUT_DIR}"

# Copy integration guide
if [[ -f "${LOCAL_SDK_PATH}/INTEGRATION_GUIDE.md" ]]; then
    echo "  Integration guide already exists"
else
    echo "  Created integration guide"
fi

# Create Package.swift for Swift Package Manager
cat > "${LOCAL_SDK_PATH}/Package.swift" << EOF
// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ConvayMeetSDK",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "ConvayMeetSDK",
            targets: ["ConvayMeetSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "ConvayMeetSDK",
            path: "ConvayMeetSDK.xcframework"
        )
    ]
)
EOF

# Create README with usage instructions
cat > "${LOCAL_SDK_PATH}/README.md" << EOF
# Convay Meet iOS SDK - Local Build

This directory contains a locally built version of the Convay Meet iOS SDK.

## SDK Information

- **SDK Version**: ${SDK_VERSION}
- **XCFramework Location**: \`ConvayMeetSDK.xcframework\`
- **Build Date**: $(date)

## Required Dependencies

⚠️ **IMPORTANT**: ConvayMeetSDK requires the following frameworks to be added to your app:

1. **GiphyUISDK.xcframework** - Located in \`RequiredFrameworks/GiphyUISDK.xcframework\`
2. **WebRTC.xcframework** - Located in \`RequiredFrameworks/WebRTC.xcframework\`

These frameworks are provided in the \`RequiredFrameworks\` directory and must be added to your app's project. They are NOT embedded in the SDK to avoid duplicate symbol conflicts (e.g., libwebp is included in both ConvayMeetSDK and GiphyUISDK).

### Adding Required Frameworks

⚠️ **CRITICAL**: These frameworks MUST be added to your app target, otherwise you'll get runtime errors like "Library not loaded: @rpath/GiphyUISDK.framework/GiphyUISDK"

**Option 1: Using the provided frameworks (Recommended)**

**Step-by-step instructions:**

1. Open your Xcode project
2. In the Project Navigator, select your **project** (blue icon at the top)
3. Select your **app target** (under TARGETS)
4. Go to the **General** tab
5. Scroll down to **Frameworks, Libraries, and Embedded Content**
6. Click the **+** button at the bottom left
7. Click **Add Other...** → **Add Files...**
8. Navigate to: \`${LOCAL_SDK_PATH}/RequiredFrameworks/GiphyUISDK.xcframework\`
9. **IMPORTANT**: Make sure "Copy items if needed" is **UNCHECKED** (since frameworks are already in place)
10. Click **Add**
11. **VERIFY**: GiphyUISDK.xcframework appears in the list with **"Embed & Sign"** selected
12. Repeat steps 6-11 for \`WebRTC.xcframework\`
13. **VERIFY**: Both frameworks show **"Embed & Sign"** status

**Troubleshooting:**
- If frameworks don't appear: Make sure you're selecting the **xcframework** folder, not individual framework files
- If "Embed & Sign" is not available: Right-click the framework → Show in Finder → Re-add it
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)

**Option 2: Via CocoaPods**

Add to your \`Podfile\`:

\`\`\`ruby
pod 'Giphy'
pod 'JitsiWebRTC'
\`\`\`

Then run \`pod install\`.

## Required Fonts

⚠️ **IMPORTANT**: The SDK requires Lato fonts. Without them, you'll see "Unrecognized font family" errors.

**Font files are located in**: \`Fonts/\` directory

### Adding Fonts to Your App

1. **Copy fonts to your project:**
   - In Finder, navigate to: \`${LOCAL_SDK_PATH}/Fonts/\`
   - Select all \`Lato-*.ttf\` files
   - Drag them into your Xcode project (into your app target's folder)
   - **IMPORTANT**: Check "Copy items if needed" ✅
   - **IMPORTANT**: Ensure your app target is checked ✅
   - Click **Finish**

2. **Register fonts in Info.plist:**
   - Open your \`Info.plist\` file
   - Add a key: \`Fonts provided by application\` (or \`UIAppFonts\`)
   - Type: **Array**
   - Add each font filename as a String item:
     - \`Lato-Black.ttf\`
     - \`Lato-BlackItalic.ttf\`
     - \`Lato-Bold.ttf\`
     - \`Lato-BoldItalic.ttf\`
     - \`Lato-Italic.ttf\`
     - \`Lato-Light.ttf\`
     - \`Lato-LightItalic.ttf\`
     - \`Lato-Medium.ttf\`
     - \`Lato-Regular.ttf\`
     - \`Lato-SemiBold.ttf\`
     - \`Lato-Thin.ttf\`
     - \`Lato-ThinItalic.ttf\`

3. **Verify fonts are in your target:**
   - Select your project → App target → **Build Phases** tab
   - Expand **Copy Bundle Resources**
   - Verify all \`Lato-*.ttf\` files are listed ✅

**For detailed step-by-step instructions, see**: \`INTEGRATION_GUIDE.md\`

## Integration Methods

### Method 1: Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Packages...**
2. Click **Add Local...**
3. Navigate to this directory: \`${LOCAL_SDK_PATH}\`
4. Click **Add Package**
5. Select **ConvayMeetSDK** and click **Add Package**
6. **IMPORTANT**: Add GiphyUISDK and WebRTC dependencies (see Required Dependencies above)

### Method 2: Manual Framework Import

**Complete Integration Steps:**

1. **Add ConvayMeetSDK Framework:**
   - In Xcode, select your project in the Project Navigator
   - Select your app target
   - Go to **General** tab
   - Scroll to **Frameworks, Libraries, and Embedded Content**
   - Click the **+** button
   - Click **Add Other... → Add Files...**
   - Navigate to: \`${LOCAL_SDK_PATH}/ConvayMeetSDK.xcframework\`
   - Click **Open**
   - **VERIFY**: Ensure **"Embed & Sign"** is selected

2. **Add Required Dependencies (CRITICAL - Do NOT skip this!):**
   - Still in **Frameworks, Libraries, and Embedded Content**
   - Click the **+** button again
   - Click **Add Other... → Add Files...**
   - Navigate to: \`${LOCAL_SDK_PATH}/RequiredFrameworks/GiphyUISDK.xcframework\`
   - Click **Open**
   - **VERIFY**: Ensure **"Embed & Sign"** is selected
   - Repeat for \`WebRTC.xcframework\`
   - **VERIFY**: All three frameworks show **"Embed & Sign"**

3. **Verify Integration:**
   - Build your project (Cmd+B)
   - If you see "Library not loaded" errors, the frameworks are not properly embedded
   - Check that all three frameworks appear in your app's **Frameworks** folder in Project Navigator

### Method 3: CocoaPods (if you have a Podfile)

Add to your \`Podfile\`:

\`\`\`ruby
pod 'ConvayMeetSDK', :path => '${LOCAL_SDK_PATH}'
\`\`\`

Then run:
\`\`\`bash
pod install
\`\`\`

## Usage Example

\`\`\`swift
import ConvayMeetSDK

// Create conference options
let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
    builder.serverURL = URL(string: "https://meet.jit.si")
    builder.room = "testRoom"
    builder.setFeatureFlag("welcomepage.enabled", withValue: false)
}

// Join conference
ConvayMeet.sharedInstance().join(options)
\`\`\`

## Documentation

For detailed integration instructions, see:
- **[INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)** - Complete step-by-step integration guide

For more information, see:
- [iOS SDK Usage Guide](../../ios/SDK_USAGE.md)
- [Quick Start Guide](../../ios/README.md)

## Rebuilding

To rebuild the SDK with latest changes:

\`\`\`bash
cd ${PROJECT_ROOT}/ios/scripts
./build-local-sdk.sh
\`\`\`
EOF

popd > /dev/null

echo ""
echo "=========================================="
echo "✅ Build Complete!"
echo "=========================================="
echo ""
echo "XCFramework Location:"
echo "  ${LOCAL_SDK_PATH}/ConvayMeetSDK.xcframework"
echo ""
echo "Swift Package Location:"
echo "  ${LOCAL_SDK_PATH}/Package.swift"
echo ""
echo "SDK Version: ${SDK_VERSION}"
echo ""
echo "To use this SDK in your iOS app:"
echo ""
echo "1. Swift Package Manager (Recommended):"
echo "   - In Xcode: File → Add Packages... → Add Local..."
echo "   - Navigate to: ${LOCAL_SDK_PATH}"
echo ""
echo "2. Manual Framework Import:"
echo "   - Drag ConvayMeetSDK.xcframework into your Xcode project"
echo "   - Ensure 'Embed & Sign' is selected"
echo ""
echo "3. Add Required Frameworks:"
echo "   - GiphyUISDK.xcframework: ${LOCAL_SDK_PATH}/RequiredFrameworks/GiphyUISDK.xcframework"
echo "   - WebRTC.xcframework: ${LOCAL_SDK_PATH}/RequiredFrameworks/WebRTC.xcframework"
echo "   These must be added to your app project (see README for details)"
echo ""
echo "4. See README for detailed instructions:"
echo "   ${LOCAL_SDK_PATH}/README.md"
echo ""
echo "=========================================="

