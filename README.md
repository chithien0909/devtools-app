# DevTools+

A modern, open-source, and cross-platform suite of developer utilities built with Flutter.

## ✨ Features

- **Base64 Encoder/Decoder**: Easily encode and decode Base64 strings.
- **JSON Formatter**: Format and minify JSON data.
- **PDF Generator**: Create PDF documents from images.
- ... and many more tools to come!

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