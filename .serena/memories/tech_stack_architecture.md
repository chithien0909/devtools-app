# Tech Stack and Architecture

## Core Technologies
- **Framework**: Flutter 3.35.5 (Dart 3.9.2)
- **State Management**: Riverpod 2.5.1
- **Routing**: GoRouter 14.2.7
- **UI**: Material Design 3 with custom theming
- **Icons**: HugeIcons 1.1.0
- **Platform**: Cross-platform (Windows, macOS, Linux, Web)

## Key Dependencies
- **UI/UX**: liquid_swipe, glassmorphism, flutter_markdown
- **Crypto**: crypto, uuid, qr_flutter
- **File Processing**: pdf, printing, image, flutter_image_compress, yaml, csv
- **Utilities**: intl, file_picker, shared_preferences, diff_match_patch, exif
- **Code Generation**: freezed, json_annotation, build_runner

## Architecture Pattern
**Modular Tool-Based Architecture**:
- Each tool is isolated in its own directory under `lib/tools/`
- Tools follow a consistent pattern: `{tool_name}_screen.dart` + optional service files
- Central registry system manages tool discovery and platform compatibility
- Service layer handles business logic separately from UI

## Directory Structure
```
lib/
├── core/           # Shared widgets, themes, constants, routing
├── models/         # Data models (ToolModel, etc.)
├── providers/      # Riverpod providers for state management
├── screens/        # Main app screens (HomeScreen, DashboardScreen, etc.)
├── services/       # Business logic services for tools
├── tools/          # Individual tool modules (25+ tools)
└── utils/          # Utility helpers
```

## Platform Support
- **Universal Tools**: Available on all platforms
- **Desktop-Only Tools**: FFmpeg transcoder, PDF split/merge, EXIF viewer
- **macOS/Linux Only**: Image format converter
- **Web Exclusions**: Desktop-only tools are excluded from web builds