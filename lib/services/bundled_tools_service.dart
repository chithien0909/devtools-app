import 'dart:io';
import 'package:path/path.dart' as path;

/// Service for managing bundled tool binaries
class BundledToolsService {
  static final BundledToolsService _instance = BundledToolsService._internal();
  factory BundledToolsService() => _instance;
  BundledToolsService._internal();

  /// Get the base directory containing bundled tools
  String get toolsDirectory {
    // For Flutter development and production, use relative path from current directory
    // This assumes the tools folder is in the project root
    return path.join(Directory.current.path, 'tools', 'bin');
  }

  /// Get the path to bundled yt-dlp binary
  String get ytDlpPath {
    final binName = Platform.isWindows ? 'yt-dlp.exe' : 'yt-dlp';
    return path.join(toolsDirectory, binName);
  }

  /// Get the path to bundled ffmpeg binary
  String get ffmpegPath {
    final binName = Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';
    return path.join(toolsDirectory, binName);
  }

  /// Check if bundled yt-dlp exists and is executable
  Future<bool> isBundledYtDlpAvailable() async {
    try {
      final file = File(ytDlpPath);
      if (!await file.exists()) return false;
      
      // Try to execute it to verify it's working
      final result = await Process.run(ytDlpPath, ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Check if bundled ffmpeg exists and is executable
  Future<bool> isBundledFfmpegAvailable() async {
    try {
      final file = File(ffmpegPath);
      if (!await file.exists()) return false;
      
      // Try to execute it to verify it's working
      final result = await Process.run(ffmpegPath, ['-version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get the appropriate yt-dlp command (bundled first, then system)
  Future<String> getYtDlpCommand() async {
    if (await isBundledYtDlpAvailable()) {
      return ytDlpPath;
    }
    return 'yt-dlp'; // Fall back to system installation
  }

  /// Get the appropriate ffmpeg command (bundled first, then system)
  Future<String> getFfmpegCommand() async {
    if (await isBundledFfmpegAvailable()) {
      return ffmpegPath;
    }
    return 'ffmpeg'; // Fall back to system installation
  }

  /// Check if either bundled or system yt-dlp is available
  Future<bool> isYtDlpAvailable() async {
    // Check bundled first
    if (await isBundledYtDlpAvailable()) return true;
    
    // Fall back to system check
    try {
      final result = await Process.run('yt-dlp', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Check if either bundled or system ffmpeg is available
  Future<bool> isFfmpegAvailable() async {
    // Check bundled first
    if (await isBundledFfmpegAvailable()) return true;
    
    // Fall back to system check
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}