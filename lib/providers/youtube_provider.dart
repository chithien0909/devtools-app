import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

import '../models/video_info.dart';
import '../services/youtube_service.dart';

// Service provider
final youtubeServiceProvider = Provider<YoutubeService>((ref) {
  return YoutubeService();
});

// URL input state
final urlInputProvider = StateProvider<String>((ref) => '');

// Selected download format
final selectedFormatProvider = StateProvider<DownloadFormat>((ref) => DownloadFormat.videoMp4);

// Download subtitles flag
final downloadSubtitlesProvider = StateProvider<bool>((ref) => false);

// Output directory
final outputDirectoryProvider = StateProvider<String>((ref) {
  // Default to Downloads folder on desktop platforms
  if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    final home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'] ?? '';
    return path.join(home, 'Downloads');
  }
  return '';
});

// Video metadata state
final videoMetadataProvider = StateNotifierProvider<VideoMetadataNotifier, AsyncValue<VideoInfo?>>((ref) {
  final service = ref.watch(youtubeServiceProvider);
  return VideoMetadataNotifier(service);
});

class VideoMetadataNotifier extends StateNotifier<AsyncValue<VideoInfo?>> {
  VideoMetadataNotifier(this._service) : super(const AsyncValue.data(null));

  final YoutubeService _service;

  Future<void> fetchMetadata(String url) async {
    if (url.trim().isEmpty) {
      state = const AsyncValue.data(null);
      return;
    }

    if (!_service.isValidYouTubeUrl(url)) {
      state = AsyncValue.error('Invalid YouTube URL', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final videoInfo = await _service.fetchMetadata(url);
      state = AsyncValue.data(videoInfo);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void clearMetadata() {
    state = const AsyncValue.data(null);
  }
}

// Download state
final downloadStateProvider = StateNotifierProvider<DownloadStateNotifier, DownloadState>((ref) {
  final service = ref.watch(youtubeServiceProvider);
  return DownloadStateNotifier(service);
});

class DownloadState {
  final bool isDownloading;
  final DownloadProgress? progress;
  final DownloadResult? result;
  final String? error;

  const DownloadState({
    this.isDownloading = false,
    this.progress,
    this.result,
    this.error,
  });

  DownloadState copyWith({
    bool? isDownloading,
    DownloadProgress? progress,
    DownloadResult? result,
    String? error,
  }) {
    return DownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      error: error ?? this.error,
    );
  }
}

class DownloadStateNotifier extends StateNotifier<DownloadState> {
  DownloadStateNotifier(this._service) : super(const DownloadState());

  final YoutubeService _service;

  Future<void> startDownload(
    String url,
    String outputDir,
    DownloadFormat format, {
    bool downloadSubtitles = false,
  }) async {
    if (state.isDownloading) return;

    state = state.copyWith(
      isDownloading: true,
      progress: null,
      result: null,
      error: null,
    );

    try {
      final result = await _service.downloadVideo(
        url,
        outputDir,
        format,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
        downloadSubtitles: downloadSubtitles,
      );

      state = state.copyWith(
        isDownloading: false,
        result: result,
        progress: result.when(
          success: (_, __, ___) => const DownloadProgress(
            percentage: 100.0,
            status: 'Download complete',
          ),
          error: (_, __) => null,
          cancelled: () => null,
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        error: e.toString(),
      );
    }
  }

  void cancelDownload() {
    // Note: Actual process cancellation would require storing the process reference
    // For now, we just reset the state
    state = const DownloadState();
  }

  void clearState() {
    state = const DownloadState();
  }
}

// Installation status provider
final ytDlpInstallationProvider = FutureProvider<bool>((ref) {
  final service = ref.watch(youtubeServiceProvider);
  return service.isYtDlpInstalled();
});