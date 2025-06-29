# PharmaPOS Image Assets

This directory contains image assets for the PharmaPOS desktop application.

## Required Images:

### Logo Images:
- `logo.png` - Main application logo (512x512px)
- `logo_small.png` - Small logo for taskbar/window (64x64px)
- `splash_logo.png` - Splash screen logo (256x256px)

### Icons:
- `pharmacy_icon.png` - Pharmacy icon (128x128px)
- `medicine_icon.png` - Medicine/pill icon (64x64px)
- `receipt_icon.png` - Receipt icon (64x64px)

### Background Images:
- `splash_bg.png` - Splash screen background (optional)
- `login_bg.png` - Login screen background (optional)

## Image Specifications:
- Format: PNG with transparency support
- Logo: High resolution (512x512px minimum)
- Icons: 64x64px or 128x128px
- Background: 1920x1080px for desktop

## Usage:
These images are referenced in the Flutter app through the `pubspec.yaml` assets section.

## Note:
Since we cannot include actual binary image files in this text-based environment, you'll need to:

1. Create or obtain your pharmacy logo
2. Save it as PNG files in the sizes mentioned above
3. Place them in this `assets/images/` directory
4. The app will automatically load them when you run `flutter pub get`

## Recommended Tools:
- GIMP (free)
- Adobe Photoshop
- Canva (for logo creation)
- Online PNG converters

## Color Scheme:
Use the app's primary color (#14B8A6) for consistency with the UI theme.