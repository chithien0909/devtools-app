# Suggested Commands for Development

## Project Setup
```bash
# Install dependencies
flutter pub get

# Generate code (for freezed/json_serializable)
flutter packages pub run build_runner build

# Clean and regenerate
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Development Commands
```bash
# Run the app
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d chrome

# Hot reload (while app is running)
r

# Hot restart (while app is running)
R
```

## Testing Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/ffmpeg_service_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests in watch mode
flutter test --watch
```

## Code Quality Commands
```bash
# Analyze code for issues
flutter analyze

# Format code
dart format .

# Format specific files
dart format lib/main.dart

# Check for outdated dependencies
flutter pub outdated

# Upgrade dependencies
flutter pub upgrade
```

## Build Commands
```bash
# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux

# Build for Web
flutter build web

# Build APK (if targeting mobile)
flutter build apk
```

## Windows-Specific Commands
```bash
# List available devices
flutter devices

# Check Flutter installation
flutter doctor

# Clean build artifacts
flutter clean

# Get packages after clean
flutter pub get

# Check FFmpeg installation (for desktop tools)
ffmpeg -version
```

## Git Commands (Windows)
```bash
# Check status
git status

# Add files
git add .

# Commit changes
git commit -m "message"

# Push changes
git push

# Pull changes
git pull

# List files
dir
dir /s *.dart

# Find files
where flutter
```

## Utility Commands
```bash
# Check Dart version
dart --version

# Check Flutter version
flutter --version

# List Flutter channels
flutter channel

# Switch Flutter channel
flutter channel stable
flutter channel beta
flutter channel master
```