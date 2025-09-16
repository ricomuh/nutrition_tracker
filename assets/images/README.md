# NutriFit AI Logo Instructions

## How to add a custom logo:

1. Add your logo image file (e.g., logo.png) to the `assets/images/` folder
2. Update the splash screen in `lib/main.dart` to use your custom image:

Replace the current icon with:

```dart
Image.asset(
  'assets/images/logo.png',
  width: 100,
  height: 100,
),
```

## App Icon Files:

For the app launcher icon, you'll need to replace the icon files in:

**Android:**

- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

**iOS:**

- Replace icon files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Recommended Tool:

Use the `flutter_launcher_icons` package to automatically generate all icon sizes from a single image.

Add to pubspec.yaml:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_icons:
  android: true
  ios: true
  image_path: "assets/images/logo.png"
```

Then run: `flutter pub get && flutter pub run flutter_launcher_icons:main`
