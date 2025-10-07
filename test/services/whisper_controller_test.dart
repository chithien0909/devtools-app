import 'package:devtools_plus/services/whisper_controller.dart';
import 'package:devtools_plus/services/whisper_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhisperController', () {
    late WhisperService mockService;
    late WhisperController controller;

    setUp(() {
      mockService = WhisperService();
      controller = WhisperController(mockService);
    });

    test('initial state is correct', () {
      final state = controller.state;

      expect(state.availability, isA<AsyncValue<WhisperAvailability>>());
      expect(state.isRunning, isFalse);
      expect(state.progress, isNull);
      expect(state.results, isEmpty);
      expect(state.stats, isNull);
      expect(state.selectedFolder, isNull);
      expect(state.selectedModel, equals(WhisperModel.base));
      expect(state.discoveredFiles, isEmpty);
      expect(state.errorMessage, isNull);
    });

    test('selectModel updates selected model', () {
      controller.selectModel(WhisperModel.large);

      expect(controller.state.selectedModel, equals(WhisperModel.large));
    });

    test('clearError removes error message', () {
      // First set an error
      controller.state = controller.state.copyWith(errorMessage: 'Test error');
      expect(controller.state.errorMessage, equals('Test error'));

      // Then clear it
      controller.clearError();
      expect(controller.state.errorMessage, isNull);
    });

    test('clearResults removes results and stats', () {
      // First set some results
      final testResults = [
        const TranscriptionResult(
          status: TranscriptionStatus.completed,
          inputFile: 'test.mp4',
          outputFile: 'test.txt',
          duration: Duration(minutes: 5),
          wordCount: 100,
          processingTime: Duration(seconds: 30),
        ),
      ];

      final testStats = const TranscriptionStats(
        totalFiles: 1,
        processedFiles: 1,
        failedFiles: 0,
        totalDuration: Duration(minutes: 5),
        totalWords: 100,
        averageProcessingTime: Duration(seconds: 30),
        totalProcessingTime: Duration(seconds: 30),
      );

      controller.state = controller.state.copyWith(
        results: testResults,
        stats: testStats,
      );

      expect(controller.state.results, isNotEmpty);
      expect(controller.state.stats, isNotNull);

      // Then clear them
      controller.clearResults();

      expect(controller.state.results, isEmpty);
      expect(controller.state.stats, isNull);
      expect(controller.state.progress, isNull);
    });

    test('copyWith creates new state with updated values', () {
      final originalState = WhisperUiState(
        availability: AsyncValue.data(
          const WhisperAvailability(isInstalled: false),
        ),
        isRunning: false,
        progress: null,
        results: const [],
        stats: null,
        selectedFolder: null,
        selectedModel: WhisperModel.base,
        discoveredFiles: const [],
        errorMessage: null,
      );

      final newState = originalState.copyWith(
        selectedModel: WhisperModel.large,
        selectedFolder: '/test/path',
        errorMessage: 'Test error',
      );

      expect(newState.selectedModel, equals(WhisperModel.large));
      expect(newState.selectedFolder, equals('/test/path'));
      expect(newState.errorMessage, equals('Test error'));

      // Original state should be unchanged
      expect(originalState.selectedModel, equals(WhisperModel.base));
      expect(originalState.selectedFolder, isNull);
      expect(originalState.errorMessage, isNull);
    });

    test('copyWith with resetProgress clears progress', () {
      const progress = TranscriptionProgress(
        currentFile: 'test.mp4',
        totalFiles: 1,
        currentFileProgress: 0.5,
        overallProgress: 0.5,
        status: 'Processing',
      );

      final originalState = WhisperUiState(
        availability: AsyncValue.data(
          const WhisperAvailability(isInstalled: false),
        ),
        isRunning: false,
        progress: progress,
        results: const [],
        stats: null,
        selectedFolder: null,
        selectedModel: WhisperModel.base,
        discoveredFiles: const [],
        errorMessage: null,
      );

      final newState = originalState.copyWith(resetProgress: true);

      expect(newState.progress, isNull);
      expect(originalState.progress, equals(progress));
    });

    test('copyWith with clearError removes error', () {
      final originalState = WhisperUiState(
        availability: AsyncValue.data(
          const WhisperAvailability(isInstalled: false),
        ),
        isRunning: false,
        progress: null,
        results: const [],
        stats: null,
        selectedFolder: null,
        selectedModel: WhisperModel.base,
        discoveredFiles: const [],
        errorMessage: 'Test error',
      );

      final newState = originalState.copyWith(clearError: true);

      expect(newState.errorMessage, isNull);
      expect(originalState.errorMessage, equals('Test error'));
    });

    test('WhisperUiState.initial creates correct initial state', () {
      final initialState = WhisperUiState.initial();

      expect(initialState.availability, equals(const AsyncValue.loading()));
      expect(initialState.isRunning, isFalse);
      expect(initialState.progress, isNull);
      expect(initialState.results, isEmpty);
      expect(initialState.stats, isNull);
      expect(initialState.selectedFolder, isNull);
      expect(initialState.selectedModel, equals(WhisperModel.base));
      expect(initialState.discoveredFiles, isEmpty);
      expect(initialState.errorMessage, isNull);
    });
  });
}
