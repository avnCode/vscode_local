#!/usr/bin/env bash
# Run this once after Flutter is installed to scaffold the Android/iOS
# boilerplate and apply the required Android permission changes.
# Usage: cd /Users/avnish.kumar/Desktop/projects/vscode_local && bash setup.sh

set -e
cd "$(dirname "$0")"

echo "==> Scaffolding Flutter project (preserves existing lib/ files)..."
flutter create --project-name vscode_local --org com.ndviewer . 2>&1 | grep -v "^  " || true

echo "==> Restoring custom pubspec.yaml (flutter create may have overwritten it)..."
# Re-write our dependencies in case flutter create replaced pubspec.yaml
cat > pubspec.yaml << 'PUBSPEC'
name: vscode_local
description: A VS Code-style file viewer for Android. View .ipynb, .py, .md, .pdf, images and more.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  file_picker: ^6.1.1
  permission_handler: ^11.3.1
  flutter_highlight: ^0.7.0
  flutter_markdown: ^0.7.3
  flutter_pdfview: ^1.3.2
  path: ^1.9.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
PUBSPEC

echo "==> Patching android/app/build.gradle (minSdkVersion -> 21)..."
GRADLE=android/app/build.gradle
if grep -q "minSdkVersion" "$GRADLE"; then
    sed -i '' 's/minSdkVersion [0-9]*/minSdkVersion 21/' "$GRADLE"
else
    echo "WARNING: Could not find minSdkVersion in $GRADLE — check manually."
fi

echo "==> Patching AndroidManifest.xml (storage permissions)..."
MANIFEST=android/app/src/main/AndroidManifest.xml

# Add permissions before <application> if not already present
if ! grep -q "MANAGE_EXTERNAL_STORAGE" "$MANIFEST"; then
    # Insert permission lines before the <application tag
    sed -i '' 's|<application|<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>\n    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>\n    <application|' "$MANIFEST"
fi

# Add requestLegacyExternalStorage to <application> tag if not present
if ! grep -q "requestLegacyExternalStorage" "$MANIFEST"; then
    sed -i '' 's|android:label="@string/app_name"|android:label="@string/app_name"\n        android:requestLegacyExternalStorage="true"|' "$MANIFEST"
fi

echo "==> Running flutter pub get..."
flutter pub get

echo "==> Running flutter analyze..."
flutter analyze

echo ""
echo "Setup complete! To build the APK locally run:"
echo "  flutter build apk --debug"
echo ""
echo "To release via GitHub:"
echo "  git add . && git commit -m 'Initial commit'"
echo "  git tag v1.0.0 && git push origin v1.0.0"
