# DevTools+

DevTools+ is a modern Flutter desktop application that bundles everyday developer utilities into one space. Swipe between tools with fluid liquid transitions, toggle dark and light modes, and jump into focused workspaces for encoding, formatting, hashing, and more.

## Features

- **Liquid swipe carousel** for exploring tools with immersive transitions.
- **Tool workspaces** delivering Base64 encode/decode, JSON prettify/minify, URL encode/decode, hashing (MD5/SHA1/SHA256), UUID generation, timestamp conversion, an Images → PDF generator, and a full Image Compressor & Converter.
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
| QR Studio | Generate / Scan | Live scanner with torch/camera controls plus QR preview generator. |
| Text Diff | Diff Viewer | Side-by-side comparison powered by `diff_match_patch`. |
| Images → PDF | Image to PDF Generator | Select, reorder, filter, watermark, preview, and export PDFs. |
| Image Compressor | Image Compressor & Converter | Batch compress, resize, convert (PNG/JPEG/WebP/PDF), strip metadata, and export. |

## Images → PDF generator

The **Images → PDF** workspace lets you:

- Pick multiple images (drag in new ones anytime) or seed the panel with 3–5 demo images.
- Reorder via drag & drop, remove unwanted items, or automatically skip tiny shots under a custom pixel threshold.
- Choose between vertical paging or a horizontal grid layout, configure page size (A4, Letter, or custom mm dimensions), tweak margins, and decide how images scale.
- Optionally add watermark, header, or footer text to every page.
- Generate a PDF on-device with the `pdf` package, preview it inline with `PdfPreview`, and save or share the final file (defaults to `output.pdf`).

> **Heads-up:** desktop platforms require camera & filesystem permissions that match the `file_picker`, `printing`, and `mobile_scanner` plugins. Flutter will emit platform warnings the first time you run after `flutter pub get`; no manual changes are needed for macOS/Windows beyond granting runtime permissions.

## Image Compressor & Converter

The **Image Compressor** workspace adds power-user controls on top of the PDF tool:

- Bulk-select images (or drop in a demo set) and re-order them before processing.
- Tune quality with a 0–100 slider, resize by percentage or custom dimensions, and choose whether to maintain aspect ratio.
- Convert between PNG, JPEG, WebP, or bundle the results into a multi-page PDF.
- Keep or strip EXIF metadata with one toggle.
- Preview every processed output (or the generated PDF) before saving, then export individual files, the combined PDF, or a ZIP archive in one click.

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
