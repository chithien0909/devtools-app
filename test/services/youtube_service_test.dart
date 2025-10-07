import 'package:flutter_test/flutter_test.dart';
import 'package:devtools_plus/services/youtube_service.dart';
import 'package:devtools_plus/models/video_info.dart';

void main() {
  group('YoutubeService', () {
    late YoutubeService service;

    setUp(() {
      service = YoutubeService();
    });

    group('URL Validation', () {
      test('should validate standard YouTube URLs', () {
        expect(service.isValidYouTubeUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
        expect(service.isValidYouTubeUrl('http://www.youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
        expect(service.isValidYouTubeUrl('https://youtube.com/watch?v=dQw4w9WgXcQ'), isTrue);
      });

      test('should validate short YouTube URLs', () {
        expect(service.isValidYouTubeUrl('https://youtu.be/dQw4w9WgXcQ'), isTrue);
        expect(service.isValidYouTubeUrl('http://youtu.be/dQw4w9WgXcQ'), isTrue);
      });

      test('should validate embed YouTube URLs', () {
        expect(service.isValidYouTubeUrl('https://www.youtube.com/embed/dQw4w9WgXcQ'), isTrue);
        expect(service.isValidYouTubeUrl('http://www.youtube.com/embed/dQw4w9WgXcQ'), isTrue);
      });

      test('should reject invalid URLs', () {
        expect(service.isValidYouTubeUrl('https://www.google.com'), isFalse);
        expect(service.isValidYouTubeUrl('not a url'), isFalse);
        expect(service.isValidYouTubeUrl(''), isFalse);
        expect(service.isValidYouTubeUrl('https://vimeo.com/123456'), isFalse);
      });
    });

    group('Video ID Extraction', () {
      test('should extract video ID from standard URLs', () {
        expect(service.extractVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
        expect(service.extractVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=30'), equals('dQw4w9WgXcQ'));
      });

      test('should extract video ID from short URLs', () {
        expect(service.extractVideoId('https://youtu.be/dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
        expect(service.extractVideoId('https://youtu.be/dQw4w9WgXcQ?t=30'), equals('dQw4w9WgXcQ'));
      });

      test('should extract video ID from embed URLs', () {
        expect(service.extractVideoId('https://www.youtube.com/embed/dQw4w9WgXcQ'), equals('dQw4w9WgXcQ'));
      });

      test('should return null for invalid URLs', () {
        expect(service.extractVideoId('https://www.google.com'), isNull);
        expect(service.extractVideoId('not a url'), isNull);
        expect(service.extractVideoId(''), isNull);
      });
    });

    group('Formatters', () {
      test('should format duration correctly', () {
        expect(service.formatDuration(30), equals('0:30'));
        expect(service.formatDuration(90), equals('1:30'));
        expect(service.formatDuration(3661), equals('1:01:01'));
        expect(service.formatDuration(0), equals('0:00'));
      });

      test('should format view count correctly', () {
        expect(service.formatViewCount(999), equals('999 views'));
        expect(service.formatViewCount(1500), equals('1.5K views'));
        expect(service.formatViewCount(1500000), equals('1.5M views'));
        expect(service.formatViewCount(1500000000), equals('1.5B views'));
      });
    });
  });

  group('DownloadFormat', () {
    test('should have correct labels', () {
      expect(DownloadFormat.videoMp4.label, equals('Video (MP4)'));
      expect(DownloadFormat.audioMp3.label, equals('Audio (MP3)'));
    });

    test('should have correct yt-dlp format strings', () {
      expect(DownloadFormat.videoMp4.ytDlpFormat, equals('best[ext=mp4]/mp4/best'));
      expect(DownloadFormat.audioMp3.ytDlpFormat, equals('best[ext=m4a]/m4a/best'));
    });
  });

  group('VideoInfo Model', () {
    test('should create VideoInfo with required fields', () {
      final videoInfo = VideoInfo(
        id: 'dQw4w9WgXcQ',
        title: 'Never Gonna Give You Up',
        channel: 'RickAstleyVEVO',
        channelId: 'UCuAXFkgsw1L7xaCfnd5JJOw',
        duration: 212,
        thumbnailUrl: 'https://example.com/thumb.jpg',
        uploadDate: '20091025',
        viewCount: 1000000000,
        description: 'Rick Astley - Never Gonna Give You Up',
      );

      expect(videoInfo.id, equals('dQw4w9WgXcQ'));
      expect(videoInfo.title, equals('Never Gonna Give You Up'));
      expect(videoInfo.channel, equals('RickAstleyVEVO'));
      expect(videoInfo.duration, equals(212));
    });
  });

  group('DownloadProgress Model', () {
    test('should create DownloadProgress with percentage and status', () {
      final progress = DownloadProgress(
        percentage: 50.5,
        status: 'Downloading...',
        speed: '1.2MiB/s',
        eta: '00:30',
        fileSize: '10.5MiB',
      );

      expect(progress.percentage, equals(50.5));
      expect(progress.status, equals('Downloading...'));
      expect(progress.speed, equals('1.2MiB/s'));
      expect(progress.eta, equals('00:30'));
      expect(progress.fileSize, equals('10.5MiB'));
    });
  });

  group('DownloadResult Model', () {
    test('should create success result', () {
      final result = DownloadResult.success(
        filePath: '/path/to/video.mp4',
        fileName: 'video.mp4',
        fileSize: 1024 * 1024 * 50, // 50MB
      );

      result.when(
        success: (filePath, fileName, fileSize) {
          expect(filePath, equals('/path/to/video.mp4'));
          expect(fileName, equals('video.mp4'));
          expect(fileSize, equals(1024 * 1024 * 50));
        },
        error: (message, details) => fail('Expected success, got error'),
        cancelled: () => fail('Expected success, got cancelled'),
      );
    });

    test('should create error result', () {
      final result = DownloadResult.error(
        message: 'Download failed',
        details: 'Network error',
      );

      result.when(
        success: (filePath, fileName, fileSize) => fail('Expected error, got success'),
        error: (message, details) {
          expect(message, equals('Download failed'));
          expect(details, equals('Network error'));
        },
        cancelled: () => fail('Expected error, got cancelled'),
      );
    });

    test('should create cancelled result', () {
      const result = DownloadResult.cancelled();

      result.when(
        success: (filePath, fileName, fileSize) => fail('Expected cancelled, got success'),
        error: (message, details) => fail('Expected cancelled, got error'),
        cancelled: () {
          // Success case for cancelled
        },
      );
    });
  });
}