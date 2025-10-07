import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import '../models/video_info.dart';

class YoutubeService {
  static const String _ytDlpCommand = 'yt-dlp';
  
  /// Check if yt-dlp is installed on the system
  Future<bool> isYtDlpInstalled() async {
    try {
      final result = await Process.run(_ytDlpCommand, ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Validate YouTube URL format
  bool isValidYouTubeUrl(String url) {
    final regex = RegExp(
      r'^https?://(www\.)?(youtube\.com/(watch\?v=|embed/|v/)|youtu\.be/)[\w-]+',
      caseSensitive: false,
    );
    return regex.hasMatch(url.trim());
  }

  /// Extract video ID from YouTube URL
  String? extractVideoId(String url) {
    final patterns = [
      RegExp(r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([^&\n?#]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }
    return null;
  }

  /// Fetch video metadata using yt-dlp
  Future<VideoInfo> fetchMetadata(String url) async {
    if (!isValidYouTubeUrl(url)) {
      throw ArgumentError('Invalid YouTube URL');
    }

    if (!await isYtDlpInstalled()) {
      throw StateError('yt-dlp is not installed. Please install it first.');
    }

    try {
      final result = await Process.run(_ytDlpCommand, [
        '--dump-json',
        '--no-playlist',
        url,
      ]);

      if (result.exitCode != 0) {
        throw Exception('Failed to fetch video metadata: ${result.stderr}');
      }

      final jsonData = jsonDecode(result.stdout as String);
      
      return VideoInfo(
        id: jsonData['id'] ?? '',
        title: jsonData['title'] ?? 'Unknown Title',
        channel: jsonData['uploader'] ?? 'Unknown Channel',
        channelId: jsonData['uploader_id'] ?? '',
        duration: (jsonData['duration'] as num?)?.toInt() ?? 0,
        thumbnailUrl: jsonData['thumbnail'] ?? '',
        uploadDate: jsonData['upload_date'] ?? '',
        viewCount: (jsonData['view_count'] as num?)?.toInt() ?? 0,
        description: jsonData['description'] ?? '',
        availableFormats: (jsonData['formats'] as List?)
            ?.map((f) => f['format_note'] as String? ?? '')
            .where((note) => note.isNotEmpty)
            .toList(),
        hasSubtitles: jsonData['subtitles'] != null,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching video metadata: $e');
    }
  }

  /// Download video with progress tracking
  Future<DownloadResult> downloadVideo(
    String url,
    String outputDir,
    DownloadFormat format, {
    Function(DownloadProgress)? onProgress,
    bool downloadSubtitles = false,
  }) async {
    if (!isValidYouTubeUrl(url)) {
      return const DownloadResult.error(message: 'Invalid YouTube URL');
    }

    if (!await isYtDlpInstalled()) {
      return const DownloadResult.error(
        message: 'yt-dlp is not installed',
        details: 'Please install yt-dlp using: pip install yt-dlp',
      );
    }

    try {
      // Create output directory if it doesn't exist
      final outputDirectory = Directory(outputDir);
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
      }

      // Build yt-dlp command arguments
      final args = <String>[
        '--format', format.ytDlpFormat,
        '--output', path.join(outputDir, '%(title)s.%(ext)s'),
        '--restrict-filenames',
        '--no-playlist',
      ];

      // Add subtitle download if requested
      if (downloadSubtitles) {
        args.addAll(['--write-subs', '--write-auto-subs', '--sub-lang', 'en']);
      }

      // Add audio conversion for MP3
      if (format == DownloadFormat.audioMp3) {
        args.addAll([
          '--extract-audio',
          '--audio-format', 'mp3',
          '--audio-quality', '0', // Best quality
        ]);
      }

      args.add(url);

      // Start the download process
      final process = await Process.start(_ytDlpCommand, args);
      final completer = Completer<DownloadResult>();
      
      String? outputFile;
      final errorBuffer = StringBuffer();

      // Listen to stderr for progress updates
      process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        debugPrint('yt-dlp stderr: $line');
        errorBuffer.writeln(line);
        
        // Parse download progress
        final progress = _parseProgressLine(line);
        if (progress != null && onProgress != null) {
          onProgress(progress);
        }
      });

      // Listen to stdout for completion info
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
        debugPrint('yt-dlp stdout: $line');
        
        // Extract output filename
        if (line.contains('has already been downloaded')) {
          final match = RegExp(r'\[download\] (.+?) has already been downloaded').firstMatch(line);
          if (match != null) {
            outputFile = match.group(1);
          }
        } else if (line.contains('Destination:')) {
          final match = RegExp(r'Destination: (.+)').firstMatch(line);
          if (match != null) {
            outputFile = match.group(1);
          }
        }
      });

      // Wait for process completion
      final exitCode = await process.exitCode;

      if (exitCode == 0 && outputFile != null) {
        final file = File(outputFile!);
        if (await file.exists()) {
          final fileSize = await file.length();
          completer.complete(DownloadResult.success(
            filePath: file.path,
            fileName: path.basename(file.path),
            fileSize: fileSize,
          ));
        } else {
          completer.complete(const DownloadResult.error(
            message: 'Download completed but file not found',
          ));
        }
      } else {
        completer.complete(DownloadResult.error(
          message: 'Download failed',
          details: errorBuffer.toString(),
        ));
      }

      return completer.future;
    } catch (e) {
      return DownloadResult.error(
        message: 'Download error',
        details: e.toString(),
      );
    }
  }

  /// Download audio only
  Future<DownloadResult> downloadAudio(
    String url,
    String outputDir, {
    Function(DownloadProgress)? onProgress,
    bool downloadSubtitles = false,
  }) async {
    return downloadVideo(
      url,
      outputDir,
      DownloadFormat.audioMp3,
      onProgress: onProgress,
      downloadSubtitles: downloadSubtitles,
    );
  }

  /// Parse progress line from yt-dlp output
  DownloadProgress? _parseProgressLine(String line) {
    // Example: [download]  45.2% of 12.34MiB at 1.23MiB/s ETA 00:05
    final progressRegex = RegExp(
      r'\[download\]\s+(\d+\.?\d*)%\s+of\s+([^\s]+)\s+at\s+([^\s]+)\s+ETA\s+([^\s]+)',
    );
    
    final match = progressRegex.firstMatch(line);
    if (match != null) {
      final percentage = double.tryParse(match.group(1) ?? '0') ?? 0.0;
      final fileSize = match.group(2) ?? '';
      final speed = match.group(3) ?? '';
      final eta = match.group(4) ?? '';
      
      return DownloadProgress(
        percentage: percentage,
        status: 'Downloading...',
        speed: speed,
        eta: eta,
        fileSize: fileSize,
      );
    }

    // Check for other status messages
    if (line.contains('[download]') && line.contains('Destination:')) {
      return const DownloadProgress(
        percentage: 0.0,
        status: 'Starting download...',
      );
    }
    
    if (line.contains('100%')) {
      return const DownloadProgress(
        percentage: 100.0,
        status: 'Download complete',
      );
    }

    return null;
  }

  /// Format duration from seconds to readable string
  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    if (duration.inHours > 0) {
      return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  /// Format view count to readable string
  String formatViewCount(int viewCount) {
    if (viewCount >= 1000000000) {
      return '${(viewCount / 1000000000).toStringAsFixed(1)}B views';
    } else if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M views';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K views';
    } else {
      return '$viewCount views';
    }
  }
}