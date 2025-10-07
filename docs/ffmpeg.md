# FFmpeg Service

DevTools+ uses `FfmpegService` to orchestrate desktop media conversions without shell interpolation.

- **Detection**: `checkAvailability()` runs `ffmpeg -version` and surfaces the version string and raw output for troubleshooting.
- **Presets**: `FfmpegRequest.preset` maps to opinionated mp4 (H.264 + AAC), webm (VP9 + Opus), and mp3 (libmp3lame) pipelines with CRF/audio bitrate overrides.
- **Safety**: All invocations use `Process.start` with argument lists, `-n` by default (no overwrite), and optional `overwrite` toggles for explicit user consent.
- **Progress**: The service emits `FfmpegProgress` objects containing raw log lines, parsed `time=`, `fps`, and `speed` hints for UI updates.
- **Telemetry**: Each job publishes a `ffmpeg_conversion_result` event with preset, duration, exit code, and flag overrides. Inject a custom `FfmpegTelemetrySink` via `ffmpegServiceProvider` to route analytics.

## Desktop UI Flow

1. **Pick source** with the file picker (accepts audio or video).
2. **Choose preset** (mp4/webm/mp3) and optionally override CRF or audio bitrate.
3. **Preview command** – the exact `ffmpeg` invocation is rendered above the actions for audit/debugging.
4. **Validate** – runs local filesystem checks before starting a job.
5. **Run / Cancel** – live progress (time/fps/speed) is streamed from stderr, while stdout/stderr tail (last 200 lines) stays visible in the log pane.
6. **Failures** bubble up the full command and log tail; users can copy/paste into a terminal for reproduction.

The UI requires desktop Flutter (Windows/Linux/macOS); on mobile/web the tool is gated off in `ToolRegistry`.
