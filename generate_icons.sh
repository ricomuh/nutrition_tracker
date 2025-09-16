#!/bin/bash

# NutriFit AI Icon Generation Script
# This script helps you generate app icons from a single image

echo "🎨 NutriFit AI Icon Generator"
echo "=============================="

echo "📋 Instructions:"
echo "1. Place your app icon image (1024x1024 PNG) in assets/images/app_icon.png"
echo "2. Run: flutter pub run flutter_launcher_icons:main"
echo "3. Your app icons will be automatically generated for all platforms!"

echo ""
echo "📱 Alternative: Manual Icon Sizes"
echo "If you prefer to create icons manually, you need these sizes:"
echo ""
echo "Android (place in android/app/src/main/res/):"
echo "  - mipmap-mdpi/ic_launcher.png (48x48)"
echo "  - mipmap-hdpi/ic_launcher.png (72x72)" 
echo "  - mipmap-xhdpi/ic_launcher.png (96x96)"
echo "  - mipmap-xxhdpi/ic_launcher.png (144x144)"
echo "  - mipmap-xxxhdpi/ic_launcher.png (192x192)"
echo ""
echo "iOS (replace files in ios/Runner/Assets.xcassets/AppIcon.appiconset/):"
echo "  - Various sizes from 20x20 to 1024x1024"
echo ""
echo "🚀 After updating icons, run:"
echo "  - flutter clean"
echo "  - flutter pub get"
echo "  - flutter run"