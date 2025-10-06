# DevTools+

A modern, open-source, and cross-platform suite of developer utilities built with Flutter.

## ✨ Features

- Base64 Converter — Encode or decode Base64 content.
- JSON Formatter — Beautify, validate, and minify JSON.
- PDF Generator — Transform images into PDF documents.
- JWT Decoder — Inspect JWT headers, payloads, and signatures.
- Hash Generator — Generate MD5, SHA, and custom hashes.
- Text Case Studio — Convert between text cases.
- QR Toolkit — Create and scan QR codes.
- UUID Generator — Generate v1/v4/v7 identifiers.
- Epoch/Time Converter — UNIX timestamps ⇄ ISO 8601.
- URL Encoder/Decoder — Encode/decode URLs and components.
- Regex Tester — Test regex with live matches and groups.
- YAML ⇄ JSON — Convert with validation.
- CSV ⇄ JSON / TSV — Convert with header handling.
- Markdown Previewer — Live preview and export to PDF.
- HMAC Generator — SHA-1/256/512 signatures (hex/base64).
- Text Diff — Side-by-side diff with highlights.
- URL Builder — Parse and build URLs, query params, fragments.
- Slugifier — Create URL-safe slugs; normalize whitespace.
- Color Tools — HEX/RGB/HSL convert; palette from image.
- Image Format Converter — PNG ⇄ JPG with quality.
- EXIF Viewer — Read image metadata (strip: placeholder).

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/devtools-plus.git
   ```
2. Navigate to the project directory:
   ```sh
   cd devtools-plus
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```

### Running the App

```sh
flutter run
```

## architecture

The project follows a modular architecture where each tool is isolated in its own directory under `lib/tools`. This makes it easy to add new tools and maintain existing ones.

- `lib/core`: Shared widgets, themes, and constants.
- `lib/models`: Data models.
- `lib/providers`: Riverpod providers for state management.
- `lib/screens`: Main screens of the app (e.g., `HomeScreen`).
- `lib/services`: Business logic for the tools.
- `lib/tools`: Individual tool modules, each containing its own screen, widgets, and services.
- `lib/utils`: Utility functions.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.