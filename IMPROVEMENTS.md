# DevTools+ Improvements Summary

## FFmpeg Integration Plan (Desktop-only)

- Scope
  - Add a desktop-only tool to convert video/audio using system-installed `ffmpeg` (Windows/macOS/Linux).
  - Initial presets: mp4 (H.264 + AAC), webm (VP9 + Opus), mp3 (libmp3lame).
  - No bundling of binaries in phase 1; rely on PATH. Add detection and friendly guidance.

- UX
  - Inputs: file picker for source media, dropdown for preset, optional bitrate/CRF fields, output path selector.
  - Actions: Validate, Run, Cancel. Show progress and stdout/stderr log.
  - Safety: quote paths, forbid shell injection by building argument lists.

- Service (FFmpegService)
  - Detect ffmpeg availability by running `ffmpeg -version` and checking exit code.
  - Build safe argument lists per preset:
    - mp4: `-y -i input -c:v libx264 -preset medium -crf <crf> -c:a aac -b:a 192k output.mp4`
    - webm: `-y -i input -c:v libvpx-vp9 -crf <crf> -b:v 0 -c:a libopus -b:a 128k output.webm`
    - mp3: `-y -i input -vn -c:a libmp3lame -b:a 192k output.mp3`
  - Stream process stdout/stderr to UI; parse simple progress (time= in stderr) when feasible.
  - Return detailed result (success, code, output path, log excerpt).

- Platform gating
  - Enable tool only on `kIsWeb == false` and (Platform.isWindows || Platform.isLinux || Platform.isMacOS).
  - Add `_isPlatformSupported` filter in `ToolRegistry`.

- Error handling
  - If ffmpeg not found: show inline instructions to install and add to PATH.
  - Validate input file existence and write permissions for output directory.
  - Surface the exact ffmpeg command and last 50 log lines on failure.

- Security & performance
  - Never pass user input through shell; use `Process.start` with arg list.
  - Use `-y` to overwrite only after explicit user confirmation in UI.
  - Consider background isolate if log parsing becomes heavy.

- Future (Phase 2)
  - Optional bundling of ffmpeg via per-OS artifacts; toggleable in settings.
  - Additional presets (HEVC, AV1), trim/cut, audio extract, thumbnails.
  - Batch conversions.

---

## Project TODO Backlog

### Media & File
- Implement FFmpegService to run system ffmpeg safely
- Build FFmpeg tool screen with presets and progress
- Register FFmpeg tool in ToolRegistry with desktop gating
- Design PDF Split & Merge service (split ranges, merge list)
- Create PDF Split & Merge screen with page preview
- Register PDF Split & Merge tool in ToolRegistry
- Implement EXIF stripping via re-encode or writer lib

### Platform & Registry
- Add app-wide platform gating in `ToolRegistry._isPlatformSupported`
- Register Image Compressor with platform gating (Windows off)

### Tools Enhancements
- Enhance Color Tools to compute palette reliably
- Add URL Builder validation and share/copy helpers
- Add Text Diff intra-line highlights for changed parts

### Documentation
- Document FFmpeg install and PATH setup in README
- Update README Features with new media tools
