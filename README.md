# DevTools+ - Developer Productivity Suite

A modern, open-source, cross-platform collection of developer utilities built with Flutter. Streamline your workflow with powerful tools for data processing, file manipulation, security analysis, and more.

## 🚀 Features

### 📊 Data Processing Tools
- **Base64 Converter** - Encode/decode Base64 content instantly
- **JSON Formatter** - Beautify, validate, and minify JSON payloads
- **CSV ⇄ JSON / TSV** - Convert CSV/TSV and JSON with header handling
- **YAML ⇄ JSON** - Convert YAML and JSON with validation
- **URL Encoder/Decoder** - Encode/decode URLs, query strings, and components
- **URL Builder** - Parse and build URLs, query params, fragments

### 🔒 Security & Privacy Tools
- **JWT Decoder** - Inspect JWT headers, payloads, and signatures
- **Hash Generator** - Generate MD5, SHA, and custom hashes rapidly
- **HMAC Generator** - Generate HMAC signatures (SHA-1/256/512)
- **EXIF Viewer** - Inspect and strip EXIF metadata from images *(desktop)*

### 📁 File Processing Tools
- **PDF Generator** - Transform images into polished PDF documents
- **PDF Split & Merge** - Split PDFs into ranges or merge multiple documents *(desktop)*
- **FFmpeg Transcoder** - Convert audio/video with system FFmpeg *(desktop)*
- **Video Transcription** - Transcribe videos using OpenAI Whisper (local model) *(desktop)*
- **Image Format Converter** - Convert PNG ⇄ JPG ⇄ WebP with quality *(macOS/Linux)*

### 🎨 Design & Utility Tools
- **Color Tools** - HEX/RGB/HSL conversions with reliable palette extraction
- **Text Case Studio** - Convert between text cases (camelCase, PascalCase, etc.)
- **QR Toolkit** - Create and scan QR codes for quick sharing
- **UUID Generator** - Generate unique identifiers (v1, v4, v7) in bulk
- **Epoch/Time Converter** - Convert between UNIX timestamps and ISO 8601
- **Regex Tester** - Test regular expressions with live matches and groups
- **Markdown Previewer** - Live Markdown preview and export to PDF
- **Text Diff** - Side-by-side text diff with intra-line highlights
- **Slugifier** - Create URL-safe slugs; normalize whitespace

## 🖥️ Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows** | ✅ Full Support | All tools available |
| **macOS** | ✅ Full Support | All tools available |
| **Linux** | ✅ Full Support | All tools available |
| **Web** | ⚠️ Limited | Desktop-only tools excluded |

### Desktop-Only Tools
- FFmpeg Transcoder (requires system FFmpeg)
- PDF Split & Merge (requires file system access)
- EXIF Viewer (requires image processing)
- Image Format Converter (macOS/Linux only)

## 📦 Installation

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.9.2+)
- Dart SDK (3.9.2+)

### Quick Start
```bash
# Clone the repository
git clone https://github.com/your-username/devtools-plus.git
cd devtools-plus

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### Platform-Specific Setup

#### FFmpeg Installation (for video/audio tools)

**Windows:**
1. Download from [Gyan.dev](https://www.gyan.dev/ffmpeg/builds/)
2. Extract to `C:\ffmpeg`
3. Add `C:\ffmpeg\bin` to PATH
4. Restart terminal/app

**macOS:**
```bash
brew install ffmpeg
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# Fedora
sudo dnf install ffmpeg
```

Verify installation:
```bash
ffmpeg -version
```

## 🏗️ Architecture

DevTools+ follows a modular architecture where each tool is isolated in its own directory, making it easy to add new functionality and maintain existing features.

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

### Key Technologies
- **Framework**: Flutter 3.35.5
- **State Management**: Riverpod 2.5.1
- **Routing**: GoRouter 14.2.7
- **UI**: Material Design 3 with custom theming
- **Icons**: HugeIcons 1.1.0

## 🛠️ Development

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/ffmpeg_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Check dependencies
flutter pub outdated
```

### Building
```bash
# Build for Windows
flutter build windows

# Build for macOS
flutter build macos

# Build for Linux
flutter build linux

# Build for Web
flutter build web
```

## 📚 Tool Documentation

### FFmpeg Transcoder
Convert video/audio files using system FFmpeg with presets and expert mode.

**Features:**
- MP4 (H.264 + AAC), WebM (VP9 + Opus), MP3 presets
- Expert mode with custom filters and metadata
- Real-time progress tracking
- Safe argument handling (no shell injection)

[Detailed FFmpeg Guide](docs/ffmpeg_tool.md)

### Video Transcription
Transcribe videos using OpenAI Whisper (local model) with multiple model sizes and batch processing.

**Features:**
- Multiple model sizes (tiny to large) for speed/accuracy balance
- Batch processing of multiple videos
- Real-time progress tracking with detailed logging
- Smart file discovery (skips already transcribed files)
- Comprehensive statistics and error handling
- Desktop-only (Windows, macOS, Linux)

**Prerequisites:**
- Python 3.8+ with Whisper installed (`pip install openai-whisper`)
- FFmpeg for video processing
- Sufficient RAM (8GB+ recommended for large model)

[Detailed Whisper Guide](docs/whisper_tool.md)

### PDF Tools
Split PDFs by page ranges or merge multiple documents with preview.

**Features:**
- Page range splitting (1-5, 10-15, etc.)
- Single page extraction
- Multiple PDF merging
- Page preview thumbnails
- Metadata preservation options

### EXIF Tools
View and strip EXIF metadata from images for privacy protection.

**Features:**
- Privacy analysis with risk assessment
- Configurable stripping levels (basic, strict, custom)
- Batch processing
- GPS location removal
- Camera info filtering

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Adding New Tools

1. Create tool directory: `lib/tools/your_tool/`
2. Implement service: `your_tool_service.dart`
3. Create UI: `your_tool_screen.dart`
4. Add to registry: `lib/core/registry/tool_registry.dart`
5. Write tests: `test/tools/your_tool/`
6. Update documentation

### Code Style
- Follow Dart/Flutter conventions
- Use snake_case for files, PascalCase for classes
- Implement proper error handling
- Write comprehensive tests
- Document public APIs

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors and users
- Open source packages that make this possible

## 📞 Support

- 🐛 [Report Issues](https://github.com/your-username/devtools-plus/issues)
- 💡 [Request Features](https://github.com/your-username/devtools-plus/issues)
- 📖 [Documentation](https://github.com/your-username/devtools-plus/wiki)
- 💬 [Discussions](https://github.com/your-username/devtools-plus/discussions)

---

**Made with ❤️ by developers, for developers.**