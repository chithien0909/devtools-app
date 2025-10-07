import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_info.freezed.dart';
part 'video_info.g.dart';

@freezed
class VideoInfo with _$VideoInfo {
  const factory VideoInfo({
    required String id,
    required String title,
    required String channel,
    required String channelId,
    required int duration, // Duration in seconds
    required String thumbnailUrl,
    required String uploadDate,
    required int viewCount,
    required String description,
    List<String>? availableFormats,
    bool? hasSubtitles,
  }) = _VideoInfo;

  factory VideoInfo.fromJson(Map<String, dynamic> json) => _$VideoInfoFromJson(json);
}

enum DownloadFormat {
  videoMp4('Video (MP4)', 'best[ext=mp4]/mp4/best'),
  audioMp3('Audio (MP3)', 'best[ext=m4a]/m4a/best');

  const DownloadFormat(this.label, this.ytDlpFormat);
  final String label;
  final String ytDlpFormat;
}

@freezed
class DownloadProgress with _$DownloadProgress {
  const factory DownloadProgress({
    required double percentage,
    required String status,
    String? speed,
    String? eta,
    String? fileSize,
  }) = _DownloadProgress;

  factory DownloadProgress.fromJson(Map<String, dynamic> json) => _$DownloadProgressFromJson(json);
}

@freezed
class DownloadResult with _$DownloadResult {
  const factory DownloadResult.success({
    required String filePath,
    required String fileName,
    required int fileSize,
  }) = DownloadSuccess;

  const factory DownloadResult.error({
    required String message,
    String? details,
  }) = DownloadError;

  const factory DownloadResult.cancelled() = DownloadCancelled;
}