import 'dart:io';

import 'package:devtools_plus/services/whisper_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhisperService', () {
    late WhisperService service;

    setUp(() {
      service = WhisperService();
    });

    test('checkAvailability returns correct structure', () async {
      final availability = await service.checkAvailability();

      expect(availability, isA<WhisperAvailability>());
      expect(availability.isInstalled, isA<bool>());
      expect(availability.pythonVersion, isA<String?>());
      expect(availability.whisperVersion, isA<String?>());
      expect(availability.ffmpegAvailable, isA<bool>());
    });

    test('discoverVideoFiles handles non-existent folder', () async {
      expect(
        () => service.discoverVideoFiles('/non/existent/path'),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('discoverVideoFiles returns empty list for empty folder', () async {
      // Create a temporary directory
      final tempDir = await Directory.systemTemp.createTemp('whisper_test_');
      try {
        final files = await service.discoverVideoFiles(tempDir.path);
        expect(files, isEmpty);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('WhisperModel enum values', () {
      expect(WhisperModel.values.length, equals(5));
      expect(WhisperModel.tiny.name, equals('tiny'));
      expect(WhisperModel.base.name, equals('base'));
      expect(WhisperModel.small.name, equals('small'));
      expect(WhisperModel.medium.name, equals('medium'));
      expect(WhisperModel.large.name, equals('large'));
    });

    test('TranscriptionStatus enum values', () {
      expect(TranscriptionStatus.values.length, equals(5));
      expect(TranscriptionStatus.idle.name, equals('idle'));
      expect(TranscriptionStatus.running.name, equals('running'));
      expect(TranscriptionStatus.completed.name, equals('completed'));
      expect(TranscriptionStatus.failed.name, equals('failed'));
      expect(TranscriptionStatus.cancelled.name, equals('cancelled'));
    });

    test('TranscriptionResult creation', () {
      const result = TranscriptionResult(
        status: TranscriptionStatus.completed,
        inputFile: 'test.mp4',
        outputFile: 'test.txt',
        duration: Duration(minutes: 5),
        wordCount: 100,
        processingTime: Duration(seconds: 30),
        transcript: 'Hello world',
      );

      expect(result.status, equals(TranscriptionStatus.completed));
      expect(result.inputFile, equals('test.mp4'));
      expect(result.outputFile, equals('test.txt'));
      expect(result.duration, equals(const Duration(minutes: 5)));
      expect(result.wordCount, equals(100));
      expect(result.processingTime, equals(const Duration(seconds: 30)));
      expect(result.transcript, equals('Hello world'));
    });

    test('TranscriptionProgress creation', () {
      const progress = TranscriptionProgress(
        currentFile: 'test.mp4',
        totalFiles: 5,
        currentFileProgress: 0.5,
        overallProgress: 0.3,
        status: 'Processing...',
        logMessage: 'Loading model',
      );

      expect(progress.currentFile, equals('test.mp4'));
      expect(progress.totalFiles, equals(5));
      expect(progress.currentFileProgress, equals(0.5));
      expect(progress.overallProgress, equals(0.3));
      expect(progress.status, equals('Processing...'));
      expect(progress.logMessage, equals('Loading model'));
    });

    test('TranscriptionStats creation', () {
      const stats = TranscriptionStats(
        totalFiles: 10,
        processedFiles: 8,
        failedFiles: 2,
        totalDuration: Duration(hours: 2),
        totalWords: 5000,
        averageProcessingTime: Duration(minutes: 5),
        totalProcessingTime: Duration(minutes: 50),
      );

      expect(stats.totalFiles, equals(10));
      expect(stats.processedFiles, equals(8));
      expect(stats.failedFiles, equals(2));
      expect(stats.totalDuration, equals(const Duration(hours: 2)));
      expect(stats.totalWords, equals(5000));
      expect(stats.averageProcessingTime, equals(const Duration(minutes: 5)));
      expect(stats.totalProcessingTime, equals(const Duration(minutes: 50)));
    });

    test('calculateStats with empty results', () {
      final stats = service.calculateStats([]);

      expect(stats.totalFiles, equals(0));
      expect(stats.processedFiles, equals(0));
      expect(stats.failedFiles, equals(0));
      expect(stats.totalDuration, equals(Duration.zero));
      expect(stats.totalWords, equals(0));
      expect(stats.averageProcessingTime, equals(Duration.zero));
      expect(stats.totalProcessingTime, equals(Duration.zero));
    });

    test('calculateStats with mixed results', () {
      final results = [
        const TranscriptionResult(
          status: TranscriptionStatus.completed,
          inputFile: 'test1.mp4',
          outputFile: 'test1.txt',
          duration: Duration(minutes: 5),
          wordCount: 100,
          processingTime: Duration(seconds: 30),
        ),
        const TranscriptionResult(
          status: TranscriptionStatus.completed,
          inputFile: 'test2.mp4',
          outputFile: 'test2.txt',
          duration: Duration(minutes: 3),
          wordCount: 50,
          processingTime: Duration(seconds: 20),
        ),
        const TranscriptionResult(
          status: TranscriptionStatus.failed,
          inputFile: 'test3.mp4',
          outputFile: 'test3.txt',
          duration: Duration.zero,
          wordCount: 0,
          processingTime: Duration(seconds: 10),
        ),
      ];

      final stats = service.calculateStats(results);

      expect(stats.totalFiles, equals(3));
      expect(stats.processedFiles, equals(2));
      expect(stats.failedFiles, equals(1));
      expect(stats.totalDuration, equals(const Duration(minutes: 8)));
      expect(stats.totalWords, equals(150));
      expect(stats.totalProcessingTime, equals(const Duration(minutes: 1)));
      expect(stats.averageProcessingTime, equals(const Duration(seconds: 25)));
    });

    test('transcribeFile with non-existent file', () async {
      final result = await service.transcribeFile(
        '/non/existent/file.mp4',
        WhisperModel.tiny,
      );

      expect(result.status, equals(TranscriptionStatus.failed));
      expect(result.error, isNotNull);
    });

    test('transcribeBatch with empty list', () async {
      final results = await service.transcribeBatch([], WhisperModel.tiny);

      expect(results, isEmpty);
    });

    test('WhisperAvailability with error', () {
      const availability = WhisperAvailability(
        isInstalled: false,
        error: 'Python not found',
      );

      expect(availability.isInstalled, isFalse);
      expect(availability.error, equals('Python not found'));
      expect(availability.pythonVersion, isNull);
      expect(availability.whisperVersion, isNull);
      expect(availability.ffmpegAvailable, isFalse);
    });

    test('WhisperAvailability with full info', () {
      const availability = WhisperAvailability(
        isInstalled: true,
        pythonVersion: '3.9.2',
        whisperVersion: '20231117',
        ffmpegAvailable: true,
      );

      expect(availability.isInstalled, isTrue);
      expect(availability.pythonVersion, equals('3.9.2'));
      expect(availability.whisperVersion, equals('20231117'));
      expect(availability.ffmpegAvailable, isTrue);
      expect(availability.error, isNull);
    });
  });
}
