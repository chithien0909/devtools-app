# DevTools+

DevTools+ is a modern Flutter desktop application that bundles everyday developer utilities into one space. Swipe between tools with fluid liquid transitions, toggle dark and light modes, and jump into focused workspaces for encoding, formatting, hashing, and more.

## Features

- **Liquid swipe carousel** for exploring tools with immersive transitions.
- **Tool workspaces** delivering Base64 encode/decode, JSON prettify/minify, URL encode/decode, hashing (MD5/SHA1/SHA256), UUID generation, and timestamp conversion today.
- **Dark & light themes** with quick toggle and editable preferences.
- **Bottom navigation** for rapid access to the Tools home, product roadmap, and settings.
- **Roadmap view** highlighting upcoming additions (QR studio, diff viewer, encryption lab, regex tester, etc.).

## Getting started

### Prerequisites

- Flutter 3.35.5 (Dart 3.9+)
- Desktop platform tooling (Visual Studio with Desktop Development workload for Windows)

### Install dependencies

```sh
flutter pub get
```

### Run on Windows desktop

```sh
flutter run -d windows
```

### Run automated checks

```sh
flutter analyze
flutter test
```

## Available tools

| Tool | Operations | Notes |
| --- | --- | --- |
| Base64 Studio | Encode / Decode | Converts between text and Base64 strings. |
| JSON Lab | Prettify / Minify | Validates JSON while formatting or compressing payloads. |
| URL Toolkit | Encode / Decode | Safely handles percent-encoding. |
| Hash Forge | MD5 / SHA1 / SHA256 | Uses the `crypto` package for one-way digests. |
| UUID Generator | v4 / v5 | v5 uses the URL namespace with user-provided seed text. |
| Time Converter | Timestamp ↔ Date | Converts between Unix ms timestamp and formatted date strings. |
| QR Studio | Generate / Scan | UI placeholders in place; functionality tracked on roadmap. |
| Text Diff | Diff Viewer | Planned feature; badge visible inside the workspace. |

## Roadmap highlights

Planned next: encryption/decryption lab (AES & RSA), regex tester, text case converter, color inspector, image ↔ Base64 utilities, and live Markdown preview. See the in-app **Roadmap** tab for updates.

## Project structure

```
lib/
├── app.dart                 # Root widget & provider wiring
├── core/theme/              # Light/dark theme definitions
├── data/models/             # Tool + operation models & catalog
├── services/                # Pure dart services (base64, json, hash, etc.)
├── ui/screens/              # Home shell, selector, roadmap, settings, workspace
├── ui/widgets/              # Reusable presentation widgets
└── viewmodels/              # ChangeNotifier view models
```

## Contributing ideas

Open the roadmap tab inside DevTools+ and drop feedback on which utilities would accelerate your workflow the most. The roadmap cards map directly to upcoming work.
"# devtools-app" 
