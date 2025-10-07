import 'dart:async';
import 'package:flutter/widgets.dart';

import 'package:devtools_plus/services/whisper_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WhisperUiState {
  const WhisperUiState({
    required this.availability,
    required this.isRunning,
    required this.progress,
    required this.results,
    required this.stats,
    this.selectedFile,
    this.startedAt,
    this.selectedFolder,
    this.selectedModel = WhisperModel.base,
    this.discoveredFiles = const [],
    this.errorMessage,
    this.backend = WhisperBackend.openaiWhisper,
    this.selectedFormats = const {TranscriptFormat.txt},
    this.outputDirectory,
    this.language,
    this.forceReRun = false,
    this.maxRetries = 0,
    this.mergeOutputs = false,
  });

  final AsyncValue<WhisperAvailability> availability;
  final bool isRunning;
  final TranscriptionProgress? progress;
  final List<TranscriptionResult> results;
  final TranscriptionStats? stats;
  final String? selectedFile;
  final DateTime? startedAt;
  final String? selectedFolder;
  final WhisperModel selectedModel;
  final List<String> discoveredFiles;
  final String? errorMessage;
  final WhisperBackend backend;
  final Set<TranscriptFormat> selectedFormats;
  final String? outputDirectory;
  final String? language;
  final bool forceReRun;
  final int maxRetries;
  final bool mergeOutputs;

  factory WhisperUiState.initial() => const WhisperUiState(
    availability: AsyncValue.loading(),
    isRunning: false,
    progress: null,
    results: [],
    stats: null,
  );

  WhisperUiState copyWith({
    AsyncValue<WhisperAvailability>? availability,
    bool? isRunning,
    TranscriptionProgress? progress,
    bool resetProgress = false,
    List<TranscriptionResult>? results,
    TranscriptionStats? stats,
    String? selectedFile,
    bool clearSelectedFile = false,
    DateTime? startedAt,
    String? selectedFolder,
    WhisperModel? selectedModel,
    List<String>? discoveredFiles,
    String? errorMessage,
    bool clearError = false,
    WhisperBackend? backend,
    Set<TranscriptFormat>? selectedFormats,
    String? outputDirectory,
    String? language,
    bool? forceReRun,
    int? maxRetries,
    bool? mergeOutputs,
  }) {
    return WhisperUiState(
      availability: availability ?? this.availability,
      isRunning: isRunning ?? this.isRunning,
      progress: resetProgress ? null : (progress ?? this.progress),
      results: results ?? this.results,
      stats: stats ?? this.stats,
      selectedFile: clearSelectedFile
          ? null
          : (selectedFile ?? this.selectedFile),
      startedAt: startedAt ?? this.startedAt,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      selectedModel: selectedModel ?? this.selectedModel,
      discoveredFiles: discoveredFiles ?? this.discoveredFiles,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      backend: backend ?? this.backend,
      selectedFormats: selectedFormats ?? this.selectedFormats,
      outputDirectory: outputDirectory ?? this.outputDirectory,
      language: language ?? this.language,
      forceReRun: forceReRun ?? this.forceReRun,
      maxRetries: maxRetries ?? this.maxRetries,
      mergeOutputs: mergeOutputs ?? this.mergeOutputs,
    );
  }
}

final whisperServiceProvider = Provider<WhisperService>((ref) {
  return WhisperService();
});

final whisperControllerProvider =
    StateNotifierProvider<WhisperController, WhisperUiState>((ref) {
      return WhisperController(ref.watch(whisperServiceProvider));
    });

class WhisperController extends StateNotifier<WhisperUiState> {
  WhisperController(this._service) : super(WhisperUiState.initial()) {
    _checkAvailability();
  }

  final WhisperService _service;
  StreamSubscription<TranscriptionProgress>? _progressSub;
  Completer<void>? _cancellationCompleter;

  Future<void> _checkAvailability() async {
    state = state.copyWith(availability: const AsyncValue.loading());
    try {
      final availability = await _service.checkAvailability();
      state = state.copyWith(availability: AsyncValue.data(availability));
    } catch (error, stackTrace) {
      state = state.copyWith(
        availability: AsyncValue.error(error, stackTrace),
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> refreshAvailability() async {
    await _checkAvailability();
  }

  void selectFile(String? filePath) {
    state = state.copyWith(selectedFile: filePath, clearError: true);
  }

  Future<void> selectFolder(String folderPath) async {
    try {
      state = state.copyWith(selectedFolder: folderPath);
      await discoverFiles();
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  Future<void> discoverFiles() async {
    if (state.selectedFolder == null) return;

    try {
      final files = await _service.discoverVideoFiles(state.selectedFolder!);
      state = state.copyWith(discoveredFiles: files);
      if (files.isEmpty) {
        state = state.copyWith(
          errorMessage:
              'No supported video files found in the selected folder. Supported: .mp4, .avi, .mov, .mkv, .wmv, .flv, .webm, .m4v',
        );
      }
    } catch (error) {
      state = state.copyWith(errorMessage: error.toString());
    }
  }

  void selectModel(WhisperModel model) {
    state = state.copyWith(selectedModel: model);
  }

  void setBackend(WhisperBackend backend) {
    state = state.copyWith(backend: backend);
  }

  void toggleFormat(TranscriptFormat format, bool enabled) {
    final next = Set<TranscriptFormat>.from(state.selectedFormats);
    if (enabled) {
      next.add(format);
    } else {
      next.remove(format);
    }
    if (next.isEmpty) next.add(TranscriptFormat.txt);
    state = state.copyWith(selectedFormats: next);
  }

  void setOutputDirectory(String? dir) {
    state = state.copyWith(outputDirectory: dir);
  }

  void setLanguage(String? language) {
    state = state.copyWith(language: language);
  }

  void setForceReRun(bool force) {
    state = state.copyWith(forceReRun: force);
  }

  void setMaxRetries(int retries) {
    state = state.copyWith(maxRetries: retries);
  }

  void setMergeOutputs(bool merge) {
    state = state.copyWith(mergeOutputs: merge);
  }

  Future<void> startTranscription() async {
    if (state.discoveredFiles.isEmpty) {
      state = state.copyWith(errorMessage: 'No files to transcribe');
      return;
    }

    await _progressSub?.cancel();
    _cancellationCompleter = Completer<void>();

    final progressController =
        StreamController<TranscriptionProgress>.broadcast();
    _progressSub = progressController.stream.listen((progress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = state.copyWith(progress: progress);
      });
    });

    state = state.copyWith(
      isRunning: true,
      results: const [],
      stats: null,
      resetProgress: true,
      clearError: true,
    );

    try {
      final results = await _service.transcribeBatch(
        state.discoveredFiles,
        state.selectedModel,
        options: TranscriptionOptions(
          backend: state.backend,
          formats: state.selectedFormats,
          outputDirectory: state.outputDirectory,
          language: state.language,
          force: state.forceReRun,
          maxRetries: state.maxRetries,
          mergeOutputs: state.mergeOutputs,
        ),
        progressController: progressController,
        cancellationCompleter: _cancellationCompleter,
      );

      final stats = _service.calculateStats(results);

      state = state.copyWith(
        isRunning: false,
        results: results,
        stats: stats,
        resetProgress: true,
      );
    } catch (error) {
      state = state.copyWith(
        isRunning: false,
        errorMessage: error.toString(),
        resetProgress: true,
      );
    } finally {
      await _progressSub?.cancel();
      _cancellationCompleter = null;
    }
  }

  Future<void> startSingleTranscription() async {
    final file = state.selectedFile;
    if (file == null || file.isEmpty) {
      state = state.copyWith(errorMessage: 'No file selected');
      return;
    }

    await _progressSub?.cancel();
    _cancellationCompleter = Completer<void>();

    final progressController =
        StreamController<TranscriptionProgress>.broadcast();
    _progressSub = progressController.stream.listen((progress) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        state = state.copyWith(progress: progress);
      });
    });

    state = state.copyWith(
      isRunning: true,
      results: const [],
      stats: null,
      resetProgress: true,
      clearError: true,
      startedAt: DateTime.now(),
    );

    try {
      final result = await _service.transcribeFile(
        file,
        state.selectedModel,
        options: TranscriptionOptions(
          backend: state.backend,
          formats: state.selectedFormats,
          outputDirectory: state.outputDirectory,
          language: state.language,
          force: state.forceReRun,
          maxRetries: state.maxRetries,
          mergeOutputs: state.mergeOutputs,
        ),
        progressController: progressController,
        cancellationCompleter: _cancellationCompleter,
      );

      state = state.copyWith(
        isRunning: false,
        results: [result],
        stats: null,
        resetProgress: true,
        startedAt: null,
      );
    } catch (error) {
      state = state.copyWith(
        isRunning: false,
        errorMessage: error.toString(),
        resetProgress: true,
        startedAt: null,
      );
    } finally {
      await _progressSub?.cancel();
      _cancellationCompleter = null;
    }
  }

  Future<void> cancelTranscription() async {
    _cancellationCompleter?.complete();
    state = state.copyWith(isRunning: false, resetProgress: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearResults() {
    state = state.copyWith(results: const [], stats: null, resetProgress: true);
  }

  @override
  void dispose() {
    _progressSub?.cancel();
    _cancellationCompleter?.complete();
    super.dispose();
  }
}
