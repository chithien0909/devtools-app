# Video Transcription Tool

Transcribe videos using OpenAI Whisper (local model) with support for multiple model sizes and batch processing.

## Features

- **Multiple Model Sizes**: Choose from tiny, base, small, medium, or large Whisper models
- **Batch Processing**: Transcribe multiple videos in a folder at once
- **Progress Tracking**: Real-time progress updates with detailed logging
- **Smart File Discovery**: Automatically finds video files and skips already transcribed ones
- **Statistics**: View processing statistics including duration, word count, and timing
- **Error Handling**: Comprehensive error handling with detailed error messages
- **Platform Support**: Desktop only (Windows, macOS, Linux)

## Prerequisites

### 1. Install Python
Make sure Python 3.8+ is installed and available in your PATH.

**Windows:**
- Download from [python.org](https://www.python.org/downloads/)
- Make sure to check "Add Python to PATH" during installation

**macOS:**
```bash
# Using Homebrew
brew install python

# Or download from python.org
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install python3 python3-pip

# CentOS/RHEL
sudo yum install python3 python3-pip
```

### 2. Install OpenAI Whisper
```bash
pip install openai-whisper
```

### 3. Install FFmpeg
Whisper requires FFmpeg for video processing.

**Windows:**
- Download from [ffmpeg.org](https://ffmpeg.org/download.html)
- Extract and add to PATH, or use chocolatey: `choco install ffmpeg`

**macOS:**
```bash
# Using Homebrew
brew install ffmpeg
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install ffmpeg

# CentOS/RHEL
sudo yum install ffmpeg
```

## Usage

### 1. Open the Tool
- Launch DevTools+ and navigate to the **Video Transcription** tool
- The app will automatically check for required dependencies

### 2. Select Folder
- Click "Select video folder" to choose a directory containing video files
- Supported formats: MP4, AVI, MOV, MKV, WMV, FLV, WebM, M4V
- The tool will automatically discover video files and skip those with existing transcripts

### 3. Choose Model
Select the Whisper model based on your needs:

| Model | Size | Speed | Accuracy | Best For |
|-------|------|-------|----------|----------|
| **Tiny** | ~39 MB | Fastest | Lowest | Quick testing, low-resource devices |
| **Base** | ~74 MB | Fast | Good | General use, good balance |
| **Small** | ~244 MB | Medium | Better | Important content, better quality |
| **Medium** | ~769 MB | Slow | High | Professional use, high accuracy |
| **Large** | ~1550 MB | Slowest | Highest | Critical content, maximum accuracy |

### 4. Start Transcription
- Click "Start Transcription" to begin processing
- Monitor progress in real-time
- Use "Cancel" to stop the current operation

### 5. View Results
- Transcripts are saved as `.txt` files alongside the original videos
- View statistics including total duration, word count, and processing time
- Click the open icon to view individual transcripts

## Model Recommendations

### For Quick Testing
- Use **Tiny** model for fast results with basic accuracy

### For General Use
- Use **Base** model for good balance of speed and accuracy

### For Important Content
- Use **Small** or **Medium** models for better accuracy

### For Professional/Critical Content
- Use **Large** model for maximum accuracy

## Troubleshooting

### "Python not found"
- Ensure Python is installed and added to your system PATH
- Try running `python --version` in terminal to verify installation

### "Whisper not installed"
- Run: `pip install openai-whisper`
- Ensure you're using the correct Python environment

### "FFmpeg not found"
- Install FFmpeg and ensure it's in your system PATH
- Try running `ffmpeg -version` in terminal to verify installation

### "Model not found" Error
- Whisper will download models automatically on first use
- Ensure you have internet connection for initial model download
- Models are cached locally after first download

### Slow Performance
- Use smaller models (tiny/base) for faster processing
- Close other applications to free up system resources
- Consider processing fewer files at once

### Memory Issues
- Use smaller models if you encounter memory errors
- Process files one at a time instead of batch processing
- Ensure sufficient RAM (8GB+ recommended for large model)

## Technical Details

### File Processing
- Videos are processed using FFmpeg for audio extraction
- Audio is then processed by Whisper for transcription
- Transcripts are saved in plain text format

### Supported Video Formats
- MP4, AVI, MOV, MKV, WMV, FLV, WebM, M4V
- Any format supported by FFmpeg

### Output Format
- Plain text files (`.txt`)
- Saved in the same directory as source videos
- Filename matches source video (e.g., `video.mp4` → `video.txt`)

### Performance Notes
- First run with each model will be slower due to model download
- Subsequent runs with the same model will be faster
- Processing time depends on video length, model size, and system performance
- Typical processing time: 0.1x to 0.5x of video duration (depending on model)

## Privacy & Security

- **Local Processing**: All transcription happens locally on your device
- **No Data Upload**: Videos and transcripts never leave your computer
- **Offline Capable**: Works without internet connection (after initial model download)
- **Secure**: No external services or APIs involved in the transcription process
