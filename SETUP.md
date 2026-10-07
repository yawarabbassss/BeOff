# BeOff — Environment & Build Setup Guide

## 1. Prerequisites

- Flutter SDK version `3.16.0` or higher
- Dart SDK `3.2.0` or higher
- Android SDK API level 34 (Android 14) with minimum SDK 24 (Android 7.0)
- Java / JDK 17
- Gradle 8.0+

---

## 2. Setting Up Environment Variables

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Configure your Supabase instance variables:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   REMOTE_FILTER_FEED_URL=https://your-project.supabase.co/functions/v1/remote_config
   ENVIRONMENT=development
   ```

*(Note: If Supabase credentials are not provided, BeOff runs gracefully in 100% offline Guest mode).*

---

## 3. Building and Running

### Run on Android Device / Emulator:
```bash
# Fetch dependencies
flutter pub get

# Run unit and widget tests
flutter test

# Run application in debug mode
flutter run -d android
```

### Build Release APK:
```bash
flutter build apk --release
```
The resulting APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.
