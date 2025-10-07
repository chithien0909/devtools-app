# Platform Support

### Desktop-only tools

| Tool ID            | Platforms              | Reason |
|--------------------|------------------------|--------|
| `ffmpeg_transcoder`| Windows / macOS / Linux| Requires system FFmpeg and process spawning. |
| `pdf_split_merge`  | Windows / macOS / Linux| Depends on desktop file system access and Syncfusion PDF. |
| `image_format`     | macOS / Linux          | Uses encoders unavailable via Windows API stack. |
| `exif_viewer`      | Windows / macOS / Linux| Reads/writes raw bytes from the file system. |

`ToolRegistry._isPlatformSupported` enforces the allow-list at runtime; default behaviour keeps other tools cross-platform unless explicitly restricted.
