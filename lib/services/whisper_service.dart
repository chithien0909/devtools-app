import 'dart:async';
import 'dart:convert';
import 'dart:io';

enum WhisperModel { tiny, base, small, medium, large }

enum WhisperBackend { openaiWhisper, whisperCpp, phoWhisper }

enum TranscriptFormat { txt, srt, json, vtt }

class TranscriptionOptions {
  const TranscriptionOptions({
    this.backend = WhisperBackend.openaiWhisper,
    this.formats = const {TranscriptFormat.txt},
    this.outputDirectory,
    this.language,
    this.force = false,
    this.maxRetries = 0,
    this.mergeOutputs = false,
  });

  final WhisperBackend backend;
  final Set<TranscriptFormat> formats;
  final String? outputDirectory;
  final String? language; // ISO-639-1 or null for auto
  final bool force; // reprocess even if outputs exist
  final int maxRetries; // additional attempts on failure
  final bool mergeOutputs; // merge all TXT into one
}

enum TranscriptionStatus { idle, running, completed, failed, cancelled }

class WhisperAvailability {
  const WhisperAvailability({
    required this.isInstalled,
    this.pythonVersion,
    this.whisperVersion,
    this.ffmpegAvailable = false,
    this.error,
  });

  final bool isInstalled;
  final String? pythonVersion;
  final String? whisperVersion;
  final bool ffmpegAvailable;
  final String? error;
}

class TranscriptionResult {
  const TranscriptionResult({
    required this.status,
    required this.inputFile,
    required this.outputFile,
    required this.duration,
    required this.wordCount,
    required this.processingTime,
    this.error,
    this.transcript,
  });

  final TranscriptionStatus status;
  final String inputFile;
  final String outputFile;
  final Duration duration;
  final int wordCount;
  final Duration processingTime;
  final String? error;
  final String? transcript;
}

class TranscriptionProgress {
  const TranscriptionProgress({
    required this.currentFile,
    required this.totalFiles,
    required this.currentFileProgress,
    required this.overallProgress,
    required this.status,
    this.logMessage,
  });

  final String currentFile;
  final int totalFiles;
  final double currentFileProgress;
  final double overallProgress;
  final String status;
  final String? logMessage;
}

class TranscriptionStats {
  const TranscriptionStats({
    required this.totalFiles,
    required this.processedFiles,
    required this.failedFiles,
    required this.totalDuration,
    required this.totalWords,
    required this.averageProcessingTime,
    required this.totalProcessingTime,
  });

  final int totalFiles;
  final int processedFiles;
  final int failedFiles;
  final Duration totalDuration;
  final int totalWords;
  final Duration averageProcessingTime;
  final Duration totalProcessingTime;
}

class WhisperService {
  WhisperService({
    this.pythonExecutable = 'python',
    this.whisperScript = 'whisper',
  });

  final String pythonExecutable;
  final String whisperScript;

  static const Map<WhisperModel, String> _modelNames = {
    WhisperModel.tiny: 'tiny',
    WhisperModel.base: 'base',
    WhisperModel.small: 'small',
    WhisperModel.medium: 'medium',
    WhisperModel.large: 'large',
  };

  static const List<String> _supportedExtensions = [
    '.mp4',
    '.avi',
    '.mov',
    '.mkv',
    '.wmv',
    '.flv',
    '.webm',
    '.m4v',
  ];

  Future<WhisperAvailability> checkAvailability() async {
    try {
      // Check Python
      final pythonResult = await Process.run(pythonExecutable, [
        '--version',
      ], runInShell: Platform.isWindows);

      if (pythonResult.exitCode != 0) {
        return WhisperAvailability(
          isInstalled: false,
          error: 'Python not found. Please install Python and add it to PATH.',
        );
      }

      final pythonVersion = pythonResult.stdout.toString().trim();

      // Check Whisper installation
      final whisperResult = await Process.run(pythonExecutable, [
        '-c',
        'import whisper; print(whisper.__version__)',
      ], runInShell: Platform.isWindows);

      if (whisperResult.exitCode != 0) {
        return WhisperAvailability(
          isInstalled: false,
          pythonVersion: pythonVersion,
          ffmpegAvailable: false,
          error: 'Whisper not installed. Run: pip install openai-whisper',
        );
      }

      final whisperVersion = whisperResult.stdout.toString().trim();

      // Check FFmpeg
      final ffmpegResult = await Process.run('ffmpeg', [
        '-version',
      ], runInShell: Platform.isWindows);

      final ffmpegAvailable = ffmpegResult.exitCode == 0;

      return WhisperAvailability(
        isInstalled: true,
        pythonVersion: pythonVersion,
        whisperVersion: whisperVersion,
        ffmpegAvailable: ffmpegAvailable,
        error: ffmpegAvailable
            ? null
            : 'FFmpeg not found. Please install FFmpeg.',
      );
    } catch (e) {
      return WhisperAvailability(
        isInstalled: false,
        error: 'Error checking dependencies: ${e.toString()}',
      );
    }
  }

  Future<List<String>> discoverVideoFiles(String folderPath) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      throw FileSystemException('Folder not found', folderPath);
    }

    final videoFiles = <String>[];
    await for (final entity in folder.list(recursive: true)) {
      if (entity is File) {
        final extension = entity.path.toLowerCase().split('.').last;
        if (_supportedExtensions.contains('.$extension')) {
          videoFiles.add(entity.path);
        }
      }
    }

    return videoFiles;
  }

  Future<TranscriptionResult> transcribeFile(
    String filePath,
    WhisperModel model, {
    TranscriptionOptions options = const TranscriptionOptions(),
    StreamController<TranscriptionProgress>? progressController,
    Completer<void>? cancellationCompleter,
  }) async {
    final stopwatch = Stopwatch()..start();
    final modelName = _modelNames[model]!;
    final outputBase = filePath.substring(0, filePath.lastIndexOf('.'));
    final outputDir =
        options.outputDirectory ?? Directory(outputBase).parent.path;
    final outputPath =
        '$outputDir/${outputBase.split(Platform.pathSeparator).last}.txt';

    try {
      // Pre-check: file exists and has supported extension
      final file = File(filePath);
      final hasSupportedExt = _supportedExtensions.any(
        (ext) => filePath.toLowerCase().endsWith(ext),
      );
      if (!await file.exists()) {
        stopwatch.stop();
        return TranscriptionResult(
          status: TranscriptionStatus.failed,
          inputFile: filePath,
          outputFile: outputPath,
          duration: Duration.zero,
          wordCount: 0,
          processingTime: stopwatch.elapsed,
          error: 'Input file not found: $filePath',
        );
      }
      if (!hasSupportedExt) {
        stopwatch.stop();
        return TranscriptionResult(
          status: TranscriptionStatus.failed,
          inputFile: filePath,
          outputFile: outputPath,
          duration: Duration.zero,
          wordCount: 0,
          processingTime: stopwatch.elapsed,
          error:
              'Unsupported file type. Supported: ${_supportedExtensions.join(', ')}',
        );
      }

      progressController?.add(
        TranscriptionProgress(
          currentFile: filePath,
          totalFiles: 1,
          currentFileProgress: 0.0,
          overallProgress: 0.0,
          status: 'Starting transcription...',
          logMessage: 'Loading model: $modelName',
        ),
      );

      // Skip if already processed and not forced
      if (!options.force) {
        final requiredOutputs = _expectedOutputs(
          outputDir,
          outputBase,
          options.formats,
        );
        final allExist = await Future.wait(
          requiredOutputs.map((p) => File(p).exists()),
        ).then((exists) => exists.every((e) => e));
        if (allExist) {
          stopwatch.stop();
          final duration = await _getVideoDuration(filePath);
          final transcript = await _readIfExists(
            '$outputDir/${outputBase.split(Platform.pathSeparator).last}.txt',
          );
          final wordCount = transcript == null
              ? 0
              : transcript
                    .split(RegExp(r'\s+'))
                    .where((w) => w.isNotEmpty)
                    .length;
          return TranscriptionResult(
            status: TranscriptionStatus.completed,
            inputFile: filePath,
            outputFile: outputPath,
            duration: duration,
            wordCount: wordCount,
            processingTime: stopwatch.elapsed,
            transcript: transcript,
          );
        }
      }

      // Build command by backend
      if (options.backend != WhisperBackend.openaiWhisper) {
        throw UnsupportedError('Selected backend not implemented yet');
      }

      final formats = options.formats.isEmpty
          ? {TranscriptFormat.txt}
          : options.formats;
      final useAll = formats.length > 1;
      final outputFormatArg = useAll ? 'all' : _formatToCli(formats.first);

      final arguments = [
        filePath,
        '--model',
        modelName,
        '--output_format',
        outputFormatArg,
        '--output_dir',
        outputDir,
        '--verbose',
        if (options.language != null &&
            options.language!.trim().isNotEmpty) ...[
          '--language',
          options.language!.trim(),
        ],
      ];

      progressController?.add(
        TranscriptionProgress(
          currentFile: filePath,
          totalFiles: 1,
          currentFileProgress: 0.1,
          overallProgress: 0.1,
          status: 'Running Whisper...',
          logMessage: 'Command: $whisperScript ${arguments.join(' ')}',
        ),
      );

      // Start the process with basic retry policy
      TranscriptionResult? attemptResult;
      int attempt = 0;
      while (attempt <= options.maxRetries) {
        final process = await Process.start(pythonExecutable, [
          '-m',
          'whisper',
          ...arguments,
        ], runInShell: Platform.isWindows);

        cancellationCompleter?.future.then((_) {
          process.kill();
        });

        final outputBuffer = StringBuffer();
        final errorBuffer = StringBuffer();

        process.stdout.listen((data) {
          final output = utf8.decode(data);
          outputBuffer.write(output);

          final progress = _parseProgress(output);
          if (progress != null) {
            progressController?.add(
              TranscriptionProgress(
                currentFile: filePath,
                totalFiles: 1,
                currentFileProgress: progress,
                overallProgress: progress,
                status: 'Transcribing...',
                logMessage: output.trim(),
              ),
            );
          }
        });

        process.stderr.listen((data) {
          final error = utf8.decode(data);
          errorBuffer.write(error);
          progressController?.add(
            TranscriptionProgress(
              currentFile: filePath,
              totalFiles: 1,
              currentFileProgress: 0.5,
              overallProgress: 0.5,
              status: 'Processing...',
              logMessage: error.trim(),
            ),
          );
        });

        final exitCode = await process.exitCode;
        if (exitCode != 0) {
          attempt++;
          if (attempt > options.maxRetries) {
            stopwatch.stop();
            return TranscriptionResult(
              status: TranscriptionStatus.failed,
              inputFile: filePath,
              outputFile: outputPath,
              duration: Duration.zero,
              wordCount: 0,
              processingTime: stopwatch.elapsed,
              error: errorBuffer.toString().isEmpty
                  ? 'Process exited with code $exitCode'
                  : errorBuffer.toString(),
            );
          }
          continue;
        }
        stopwatch.stop();

        // Read the transcript
        final transcriptFile = File(outputPath);
        String? transcript;
        int wordCount = 0;

        if (await transcriptFile.exists()) {
          transcript = await transcriptFile.readAsString();
          wordCount = transcript
              .split(RegExp(r'\s+'))
              .where((w) => w.isNotEmpty)
              .length;
        }

        final duration = await _getVideoDuration(filePath);

        progressController?.add(
          TranscriptionProgress(
            currentFile: filePath,
            totalFiles: 1,
            currentFileProgress: 1.0,
            overallProgress: 1.0,
            status: 'Completed',
            logMessage: 'Transcription completed successfully',
          ),
        );

        attemptResult = TranscriptionResult(
          status: TranscriptionStatus.completed,
          inputFile: filePath,
          outputFile: outputPath,
          duration: duration,
          wordCount: wordCount,
          processingTime: stopwatch.elapsed,
          transcript: transcript,
        );
        break;
      }

      if (attemptResult != null) return attemptResult;
      // Fallback return if something unexpected happened
      return TranscriptionResult(
        status: TranscriptionStatus.failed,
        inputFile: filePath,
        outputFile: outputPath,
        duration: Duration.zero,
        wordCount: 0,
        processingTime: stopwatch.elapsed,
        error: 'Unknown error',
      );
    } catch (e) {
      stopwatch.stop();
      return TranscriptionResult(
        status: TranscriptionStatus.failed,
        inputFile: filePath,
        outputFile: outputPath,
        duration: Duration.zero,
        wordCount: 0,
        processingTime: stopwatch.elapsed,
        error: e.toString(),
      );
    }
  }

  Future<List<TranscriptionResult>> transcribeBatch(
    List<String> files,
    WhisperModel model, {
    TranscriptionOptions options = const TranscriptionOptions(),
    StreamController<TranscriptionProgress>? progressController,
    Completer<void>? cancellationCompleter,
  }) async {
    final results = <TranscriptionResult>[];
    final totalFiles = files.length;

    for (int i = 0; i < files.length; i++) {
      if (cancellationCompleter?.isCompleted == true) {
        results.add(
          TranscriptionResult(
            status: TranscriptionStatus.cancelled,
            inputFile: files[i],
            outputFile: '',
            duration: Duration.zero,
            wordCount: 0,
            processingTime: Duration.zero,
          ),
        );
        continue;
      }

      final file = files[i];
      final overallProgress = i / totalFiles;

      progressController?.add(
        TranscriptionProgress(
          currentFile: file,
          totalFiles: totalFiles,
          currentFileProgress: 0.0,
          overallProgress: overallProgress,
          status: 'Processing file ${i + 1} of $totalFiles',
        ),
      );

      final result = await transcribeFile(
        file,
        model,
        options: options,
        progressController: progressController,
        cancellationCompleter: cancellationCompleter,
      );

      results.add(result);
    }

    if (options.mergeOutputs && results.isNotEmpty) {
      await _mergeTxtOutputs(results, options.outputDirectory);
    }

    return results;
  }

  TranscriptionStats calculateStats(List<TranscriptionResult> results) {
    final processedFiles = results
        .where((r) => r.status == TranscriptionStatus.completed)
        .length;
    final failedFiles = results
        .where((r) => r.status == TranscriptionStatus.failed)
        .length;

    final totalDuration = results.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.duration,
    );

    final totalWords = results.fold<int>(
      0,
      (sum, result) => sum + result.wordCount,
    );

    final totalProcessingTime = results.fold<Duration>(
      Duration.zero,
      (sum, result) => sum + result.processingTime,
    );

    final averageProcessingTime = processedFiles > 0
        ? Duration(
            milliseconds: totalProcessingTime.inMilliseconds ~/ processedFiles,
          )
        : Duration.zero;

    return TranscriptionStats(
      totalFiles: results.length,
      processedFiles: processedFiles,
      failedFiles: failedFiles,
      totalDuration: totalDuration,
      totalWords: totalWords,
      averageProcessingTime: averageProcessingTime,
      totalProcessingTime: totalProcessingTime,
    );
  }

  List<String> _expectedOutputs(
    String outputDir,
    String outputBase,
    Set<TranscriptFormat> formats,
  ) {
    final baseName = outputBase.split(Platform.pathSeparator).last;
    final targets = <String>[];
    for (final f in formats.isEmpty ? {TranscriptFormat.txt} : formats) {
      switch (f) {
        case TranscriptFormat.txt:
          targets.add('$outputDir/$baseName.txt');
          break;
        case TranscriptFormat.srt:
          targets.add('$outputDir/$baseName.srt');
          break;
        case TranscriptFormat.json:
          targets.add('$outputDir/$baseName.json');
          break;
        case TranscriptFormat.vtt:
          targets.add('$outputDir/$baseName.vtt');
          break;
      }
    }
    return targets;
  }

  String _formatToCli(TranscriptFormat f) {
    switch (f) {
      case TranscriptFormat.txt:
        return 'txt';
      case TranscriptFormat.srt:
        return 'srt';
      case TranscriptFormat.json:
        return 'json';
      case TranscriptFormat.vtt:
        return 'vtt';
    }
  }

  Future<String?> _readIfExists(String path) async {
    final f = File(path);
    if (await f.exists()) return f.readAsString();
    return null;
  }

  Future<void> _mergeTxtOutputs(
    List<TranscriptionResult> results,
    String? outputDirectory,
  ) async {
    final completed = results
        .where((r) => r.status == TranscriptionStatus.completed)
        .toList();
    if (completed.isEmpty) return;
    final buffer = StringBuffer();
    for (final r in completed) {
      buffer.writeln('# ${r.inputFile.split(Platform.pathSeparator).last}');
      buffer.writeln(r.transcript ?? '');
      buffer.writeln();
    }
    final first = completed.first;
    final dir = outputDirectory ?? Directory(first.outputFile).parent.path;
    final mergedPath = '$dir/_merged_transcripts.txt';
    await File(mergedPath).writeAsString(buffer.toString());
  }

  double? _parseProgress(String output) {
    // Parse whisper progress output
    // Example: "Processing audio: 45%"
    final progressMatch = RegExp(r'(\d+)%').firstMatch(output);
    if (progressMatch != null) {
      return int.parse(progressMatch.group(1)!) / 100.0;
    }
    return null;
  }

  Future<Duration> _getVideoDuration(String filePath) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v',
        'quiet',
        '-show_entries',
        'format=duration',
        '-of',
        'csv=p=0',
        filePath,
      ], runInShell: Platform.isWindows);

      if (result.exitCode == 0) {
        final durationStr = result.stdout.toString().trim();
        final seconds = double.tryParse(durationStr);
        if (seconds != null) {
          return Duration(milliseconds: (seconds * 1000).round());
        }
      }
    } catch (e) {
      // Ignore errors, return zero duration
    }

    return Duration.zero;
  }
}
