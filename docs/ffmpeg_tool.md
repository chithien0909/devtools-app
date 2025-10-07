# FFmpeg Transcoder Tool

## Overview
The FFmpeg Transcoder tool allows you to convert video and audio files using the system-installed FFmpeg binary. It supports multiple presets and includes an expert mode for advanced users.

## Prerequisites

### FFmpeg Installation

**Windows:**
1. Download FFmpeg from [Gyan.dev](https://www.gyan.dev/ffmpeg/builds/)
2. Extract the archive to `C:\ffmpeg`
3. Add `C:\ffmpeg\bin` to your system PATH
4. Restart your terminal/application
5. Verify installation: `ffmpeg -version`

**macOS:**
```bash
brew install ffmpeg
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install ffmpeg
```

**Linux (Fedora):**
```bash
sudo dnf install ffmpeg
```

## Features

### Basic Mode
- **MP4 Preset**: H.264 video + AAC audio (default CRF: 23)
- **WebM Preset**: VP9 video + Opus audio (default CRF: 32)
- **MP3 Preset**: Audio-only conversion (libmp3lame)

### Expert Mode
- Custom video filters (scale, fps, etc.)
- Audio filters (volume, highpass, etc.)
- Metadata editing (title, artist)
- Custom presets (ultrafast, slow, etc.)
- Additional output options

## Usage

### Basic Conversion
1. Select input media file
2. Choose output directory
3. Select preset (MP4/WebM/MP3)
4. Adjust CRF and audio bitrate if needed
5. Click "Run" to start conversion

### Expert Mode
1. Enable "Expert Mode" toggle
2. Configure video/audio filters
3. Set custom metadata
4. Add additional FFmpeg arguments
5. Run conversion

## Preset Details

| Preset | Video Codec | Audio Codec | Default CRF | Use Case |
|--------|-------------|-------------|-------------|----------|
| MP4    | H.264       | AAC         | 23          | Universal compatibility |
| WebM   | VP9         | Opus        | 32          | Web optimization |
| MP3    | None        | MP3         | N/A         | Audio-only |

## CRF Values
- **18-23**: High quality (larger files)
- **24-28**: Good quality (balanced)
- **29-35**: Lower quality (smaller files)

## Common Video Filters
- `scale=1920:1080` - Resize to 1080p
- `fps=30` - Set frame rate to 30fps
- `scale=1280:720,fps=24` - Resize and set frame rate

## Common Audio Filters
- `volume=0.8` - Reduce volume to 80%
- `highpass=f=200` - Remove low frequencies
- `lowpass=f=8000` - Remove high frequencies

## Troubleshooting

### FFmpeg Not Found
- Ensure FFmpeg is installed and in PATH
- Restart the application after installation
- Check installation with `ffmpeg -version`

### Conversion Fails
- Check input file format is supported
- Ensure output directory is writable
- Verify sufficient disk space
- Check FFmpeg logs for specific errors

### Performance Issues
- Use faster presets (ultrafast, fast)
- Reduce output resolution
- Lower CRF values for smaller files
- Close other applications

## Security Notes
- All FFmpeg commands use safe argument lists
- No shell injection vulnerabilities
- File paths are properly quoted
- User input is validated before processing

## Advanced Usage

### Custom Presets
Create custom presets by modifying the expert options:
- Video: `-preset ultrafast -crf 28`
- Audio: `-b:a 128k -ac 2`
- Output: `-movflags +faststart`

### Batch Processing
For multiple files, use the tool multiple times or consider command-line FFmpeg for automation.

### Quality Optimization
- Use CRF 18-20 for archival quality
- Use CRF 23-25 for streaming
- Use CRF 28-30 for previews
