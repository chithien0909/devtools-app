# YouTube Downloader

The YouTube Downloader is a feature within DevTools+ that allows you to download YouTube videos and audio using the powerful `yt-dlp` library.

## 🚀 Features

- **Video Downloads**: Download YouTube videos in MP4 format (highest quality available)
- **Audio Downloads**: Extract audio and save as MP3 format
- **Metadata Preview**: See video title, channel, duration, view count, and thumbnail before downloading
- **Progress Tracking**: Real-time download progress with speed and ETA information
- **Subtitle Support**: Optional download of subtitles when available
- **Directory Selection**: Choose where to save downloaded files
- **Error Handling**: Clear error messages and status indicators

## 📋 Requirements

### System Dependencies

1. **yt-dlp**: The core download engine
   ```bash
   pip install yt-dlp
   ```

2. **FFmpeg** (for audio conversion): Required for MP3 audio extraction
   - **macOS**: `brew install ffmpeg`
   - **Linux**: `sudo apt install ffmpeg` (Ubuntu/Debian) or `sudo dnf install ffmpeg` (Fedora)
   - **Windows**: Download from [ffmpeg.org](https://ffmpeg.org/download.html)

### Platform Support

- ✅ macOS
- ✅ Linux
- ✅ Windows
- ❌ Web (not supported due to system process requirements)

## 🎯 Usage

### Basic Download

1. **Open YouTube Downloader**: Find it in the Utility tools category
2. **Paste URL**: Enter a YouTube video URL in the input field
3. **Preview Video**: The app will automatically fetch and display video metadata
4. **Choose Format**: Select either Video (MP4) or Audio (MP3)
5. **Select Directory**: Choose where to save the downloaded file
6. **Start Download**: Click the "Start Download" button

### Advanced Options

- **Subtitle Download**: Enable the checkbox to download subtitles when available
- **Progress Monitoring**: Watch real-time progress with percentage, speed, and ETA
- **Cancel Download**: Stop the download process at any time
- **Open Folder**: Quickly access the download location after completion

### URL Support

The YouTube Downloader supports various YouTube URL formats:
- Standard: `https://www.youtube.com/watch?v=VIDEO_ID`
- Short: `https://youtu.be/VIDEO_ID`
- Embed: `https://www.youtube.com/embed/VIDEO_ID`

## 🏗️ Architecture

### Service Layer
- **YoutubeService**: Core service handling yt-dlp integration
- **Process Management**: Executes yt-dlp commands and parses output
- **Progress Parsing**: Extracts download progress from yt-dlp logs

### State Management
- **Riverpod Providers**: Manage application state
- **Reactive UI**: Automatically updates based on state changes
- **Error Handling**: Comprehensive error state management

### Models
- **VideoInfo**: Metadata model for video information
- **DownloadProgress**: Progress tracking model
- **DownloadResult**: Result handling with success/error states

## 🔧 Configuration

### Output Directory
The app defaults to your system's Downloads folder but allows custom selection:
- **macOS**: `~/Downloads`
- **Linux**: `~/Downloads`
- **Windows**: `%USERPROFILE%\Downloads`

### File Naming
Downloaded files use the video title as filename with restricted characters for compatibility:
- Special characters are replaced with safe alternatives
- Maximum filename length is respected
- Format: `{Video Title}.{extension}`

## 🚨 Troubleshooting

### Common Issues

#### yt-dlp Not Found
```
Error: yt-dlp is not installed
Solution: Install yt-dlp using: pip install yt-dlp
```

#### FFmpeg Missing (for MP3 downloads)
```
Error: ffmpeg not found
Solution: Install FFmpeg for your platform (see requirements above)
```

#### Permission Errors
```
Error: Permission denied
Solution: Check write permissions for the selected output directory
```

#### Network Issues
```
Error: Failed to fetch video metadata
Solution: Check internet connection and verify the YouTube URL is accessible
```

### Debug Information

The app provides detailed error messages including:
- Installation status checks
- URL validation feedback
- Download process logs
- File system error details

## 🔒 Privacy & Security

- **No Data Collection**: The app doesn't collect or store personal information
- **Local Processing**: All downloads are processed locally on your machine
- **Secure Downloads**: Uses HTTPS connections for all network requests
- **File Safety**: Downloaded files are saved directly to your chosen directory

## ⚡ Performance

### Optimization Features
- **Efficient Processing**: Minimal resource usage during downloads
- **Progress Streaming**: Real-time progress updates without blocking UI
- **Memory Management**: Optimized for large video downloads
- **Cancellation**: Ability to stop downloads immediately

### Best Practices
- Use wired internet connection for large downloads
- Ensure sufficient disk space before starting
- Close other network-intensive applications during download
- Choose output directory on fast storage (SSD recommended)

## 📝 Examples

### Download Video
1. URL: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
2. Format: Video (MP4)
3. Subtitles: Enabled
4. Output: `~/Downloads/Never_Gonna_Give_You_Up.mp4`

### Download Audio Only
1. URL: `https://youtu.be/dQw4w9WgXcQ`
2. Format: Audio (MP3)
3. Subtitles: Disabled
4. Output: `~/Downloads/Never_Gonna_Give_You_Up.mp3`

## 🤝 Contributing

To contribute to the YouTube Downloader feature:

1. **Testing**: Test with various YouTube URLs and formats
2. **Bug Reports**: Report issues with specific URLs and error messages
3. **Feature Requests**: Suggest improvements or additional formats
4. **Code Contributions**: Submit PRs following the project guidelines

## 📄 License

This feature is part of DevTools+ and follows the same license terms as the main application.

---

**Note**: This feature is for personal use only. Please respect YouTube's Terms of Service and copyright laws when downloading content.