import 'dart:io';
import 'dart:convert';

import 'package:devtools_plus/services/whisper_controller.dart';
import 'package:devtools_plus/services/whisper_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

class WhisperScreen extends ConsumerStatefulWidget {
  const WhisperScreen({super.key});

  @override
  ConsumerState<WhisperScreen> createState() => _WhisperScreenState();
}

class _WhisperScreenState extends ConsumerState<WhisperScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(whisperControllerProvider);
    final controller = ref.read(whisperControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Transcription'),
        actions: [
          IconButton(
            tooltip: 'Re-check dependencies',
            onPressed: controller.refreshAvailability,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvailabilityBanner(state: state),
                  const SizedBox(height: 24),
                  _FileSelectionSection(state: state, controller: controller),
                  const SizedBox(height: 24),
                  _ModelSelectionSection(state: state, controller: controller),
                  const SizedBox(height: 24),
                  _OptionsSection(state: state, controller: controller),
                  const SizedBox(height: 24),
                  _ControlButtons(state: state, controller: controller),
                  if (state.progress != null) ...[
                    const SizedBox(height: 16),
                    _ProgressSection(progress: state.progress!, startedAt: state.startedAt),
                  ],
                  if (state.stats != null) ...[
                    const SizedBox(height: 16),
                    _StatsSection(stats: state.stats!),
                  ],
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    _ErrorSection(error: state.errorMessage!),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverFillRemaining(
              child: _ResultsSection(results: state.results),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvailabilityBanner extends StatelessWidget {
  const _AvailabilityBanner({required this.state});

  final WhisperUiState state;

  @override
  Widget build(BuildContext context) {
    return state.availability.when(
      data: (availability) {
        if (availability.isInstalled) {
          return Card(
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                'Whisper Ready (${availability.whisperVersion ?? 'unknown version'})',
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Python: ${availability.pythonVersion ?? 'unknown'}'),
                  Text(
                    'FFmpeg: ${availability.ffmpegAvailable ? 'Available' : 'Not found'}',
                  ),
                  if (availability.error != null)
                    Text(
                      availability.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          );
        }
        return Card(
          color: Theme.of(
            context,
          ).colorScheme.errorContainer.withValues(alpha: 0.3),
          child: ListTile(
            leading: const Icon(Icons.error_outline, color: Colors.red),
            title: const Text('Dependencies Missing'),
            subtitle: Text(
              availability.error ?? 'Please install required dependencies',
            ),
          ),
        );
      },
      error: (error, _) => Card(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.3),
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: Colors.red),
          title: const Text('Error Checking Dependencies'),
          subtitle: Text(error.toString()),
        ),
      ),
      loading: () => const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Checking dependencies...'),
        ),
      ),
    );
  }
}

class _FileSelectionSection extends StatelessWidget {
  const _FileSelectionSection({required this.state, required this.controller});

  final WhisperUiState state;
  final WhisperController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.availability.value?.isInstalled == true
                        ? () => _selectFile(controller)
                        : null,
                    icon: const Icon(Icons.video_file),
                    label: Text(state.selectedFile == null
                        ? 'Select video file (.mp4, .mov, .mkv)'
                        : 'File: ${p.basename(state.selectedFile!)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.availability.value?.isInstalled == true
                        ? () => _selectFolder(controller)
                        : null,
                    icon: const Icon(Icons.folder),
                    label: Text(state.selectedFolder == null
                        ? 'Select folder (batch)'
                        : 'Folder: ${p.basename(state.selectedFolder!)}'),
                  ),
                ),
              ],
            ),
            if (state.selectedFile != null) ...[
              const SizedBox(height: 8),
              Text(p.dirname(state.selectedFile!),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      )),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile(WhisperController controller) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: ['mp4', 'mov', 'mkv'],
    );
    if (res != null && res.files.single.path != null) {
      controller.selectFile(res.files.single.path);
    }
  }

  Future<void> _selectFolder(WhisperController controller) async {
    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir != null) {
      controller.selectFolder(dir);
    }
  }
}

class _ModelSelectionSection extends StatelessWidget {
  const _ModelSelectionSection({required this.state, required this.controller});

  final WhisperUiState state;
  final WhisperController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Model Selection',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WhisperModel>(
              initialValue: state.selectedModel,
              onChanged: state.isRunning
                  ? null
                  : (WhisperModel? model) {
                      if (model != null) controller.selectModel(model);
                    },
              decoration: const InputDecoration(
                labelText: 'Whisper Model',
                border: OutlineInputBorder(),
              ),
              items: WhisperModel.values.map((model) {
                return DropdownMenuItem(
                  value: model,
                  child: Text(_getModelDescription(model)),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getModelInfo(state.selectedModel),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getModelDescription(WhisperModel model) {
    switch (model) {
      case WhisperModel.tiny:
        return 'Tiny (~39 MB) - Fastest, lowest accuracy';
      case WhisperModel.base:
        return 'Base (~74 MB) - Good balance';
      case WhisperModel.small:
        return 'Small (~244 MB) - Better accuracy';
      case WhisperModel.medium:
        return 'Medium (~769 MB) - High accuracy';
      case WhisperModel.large:
        return 'Large (~1550 MB) - Highest accuracy';
    }
  }

  String _getModelInfo(WhisperModel model) {
    switch (model) {
      case WhisperModel.tiny:
        return 'Best for: Quick testing, low-resource devices';
      case WhisperModel.base:
        return 'Best for: General use, good speed/accuracy balance';
      case WhisperModel.small:
        return 'Best for: Important content, better quality needed';
      case WhisperModel.medium:
        return 'Best for: Professional use, high accuracy required';
      case WhisperModel.large:
        return 'Best for: Critical content, maximum accuracy';
    }
  }
}

class _ControlButtons extends StatelessWidget {
  const _ControlButtons({required this.state, required this.controller});

  final WhisperUiState state;
  final WhisperController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: state.isRunning || state.selectedFile == null
              ? null
              : controller.startSingleTranscription,
          icon: const Icon(Icons.play_arrow),
          label: Text(state.isRunning ? 'Running...' : 'Start Transcription'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: state.isRunning ? controller.cancelTranscription : null,
          icon: const Icon(Icons.stop),
          label: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: state.results.isNotEmpty ? controller.clearResults : null,
          icon: const Icon(Icons.clear),
          label: const Text('Clear Results'),
        ),
        const Spacer(),
        if (state.selectedFile != null)
          ElevatedButton.icon(
            onPressed: () => _openFolder(p.dirname(state.selectedFile!)),
            icon: const Icon(Icons.folder_open),
            label: const Text('Open Folder'),
          ),
        if (state.selectedFolder != null) ...[
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _openFolder(state.selectedFolder!),
            icon: const Icon(Icons.folder_open),
            label: const Text('Open Batch Folder'),
          ),
        ],
      ],
    );
  }

  void _openFolder(String folderPath) {
    if (Platform.isWindows) {
      Process.run('explorer', [folderPath]);
    } else if (Platform.isMacOS) {
      Process.run('open', [folderPath]);
    } else if (Platform.isLinux) {
      Process.run('xdg-open', [folderPath]);
    }
  }
}

class _OptionsSection extends StatelessWidget {
  const _OptionsSection({required this.state, required this.controller});

  final WhisperUiState state;
  final WhisperController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Options', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<WhisperBackend>(
                  value: state.backend,
                  onChanged: state.isRunning ? null : (b) { if (b != null) controller.setBackend(b); },
                  decoration: const InputDecoration(labelText: 'Backend', border: OutlineInputBorder()),
                  items: WhisperBackend.values.map((b) => DropdownMenuItem(value: b, child: Text(_backendLabel(b)))).toList(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: state.language ?? '',
                  onChanged: state.isRunning ? null : (v) => controller.setLanguage(v.isEmpty ? null : v),
                  decoration: const InputDecoration(labelText: 'Language (blank = auto)', border: OutlineInputBorder()),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Wrap(spacing: 12, runSpacing: 8, children: [
              FilterChip(
                label: const Text('TXT'),
                selected: state.selectedFormats.contains(TranscriptFormat.txt),
                onSelected: state.isRunning ? null : (v) => controller.toggleFormat(TranscriptFormat.txt, v),
              ),
              FilterChip(
                label: const Text('SRT'),
                selected: state.selectedFormats.contains(TranscriptFormat.srt),
                onSelected: state.isRunning ? null : (v) => controller.toggleFormat(TranscriptFormat.srt, v),
              ),
              FilterChip(
                label: const Text('JSON'),
                selected: state.selectedFormats.contains(TranscriptFormat.json),
                onSelected: state.isRunning ? null : (v) => controller.toggleFormat(TranscriptFormat.json, v),
              ),
              FilterChip(
                label: const Text('VTT'),
                selected: state.selectedFormats.contains(TranscriptFormat.vtt),
                onSelected: state.isRunning ? null : (v) => controller.toggleFormat(TranscriptFormat.vtt, v),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  controller: TextEditingController(text: state.outputDirectory ?? ''),
                  decoration: const InputDecoration(labelText: 'Output directory (default: same as input)', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: state.isRunning
                    ? null
                    : () async {
                        final dir = await FilePicker.platform.getDirectoryPath();
                        if (dir != null) controller.setOutputDirectory(dir);
                      },
                icon: const Icon(Icons.folder_open),
                label: const Text('Choose'),
              ),
              const SizedBox(width: 8),
              if (state.outputDirectory != null)
                TextButton(
                  onPressed: state.isRunning ? null : () => controller.setOutputDirectory(null),
                  child: const Text('Reset'),
                ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Retries', border: OutlineInputBorder()),
                  child: Slider(
                    value: state.maxRetries.toDouble(),
                    min: 0,
                    max: 3,
                    divisions: 3,
                    label: '${state.maxRetries}',
                    onChanged: state.isRunning ? null : (v) => controller.setMaxRetries(v.toInt()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Checkbox(
                value: state.forceReRun,
                onChanged: state.isRunning ? null : (v) => controller.setForceReRun(v ?? false),
              ),
              const Text('Force re-run'),
              const SizedBox(width: 16),
              Checkbox(
                value: state.mergeOutputs,
                onChanged: state.isRunning ? null : (v) => controller.setMergeOutputs(v ?? false),
              ),
              const Text('Merge TXT outputs'),
            ]),
          ],
        ),
      ),
    );
  }

  String _backendLabel(WhisperBackend b) {
    switch (b) {
      case WhisperBackend.openaiWhisper:
        return 'OpenAI Whisper (Python)';
      case WhisperBackend.whisperCpp:
        return 'whisper.cpp';
      case WhisperBackend.phoWhisper:
        return 'Pho-Whisper';
    }
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.progress, this.startedAt});

  final TranscriptionProgress progress;
  final DateTime? startedAt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.overallProgress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              () {
                final pct = (progress.overallProgress * 100).toStringAsFixed(1);
                final elapsed = startedAt == null
                    ? ''
                    : ' • Elapsed: ' + WhisperFormatters.duration(DateTime.now().difference(startedAt!));
                return '$pct% - ${progress.status}$elapsed';
              }(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (progress.logMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                progress.logMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats});

  final TranscriptionStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Files',
                    value: stats.totalFiles.toString(),
                    icon: Icons.video_file,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Processed',
                    value: stats.processedFiles.toString(),
                    icon: Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Failed',
                    value: stats.failedFiles.toString(),
                    icon: Icons.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Total Duration',
                    value: WhisperFormatters.duration(stats.totalDuration),
                    icon: Icons.timer,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Total Words',
                    value: stats.totalWords.toString(),
                    icon: Icons.text_fields,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Avg Time/File',
                    value: WhisperFormatters.duration(stats.averageProcessingTime),
                    icon: Icons.speed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WhisperFormatters {
  static String duration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}


class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  const _ResultsSection({required this.results});

  final List<TranscriptionResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_file_outlined,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No transcription results yet',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final result = results.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transcript', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(p.basename(result.inputFile), style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                IconButton(
                  tooltip: 'Copy to clipboard',
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    final text = result.transcript ?? '';
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transcript copied')),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Save as .txt',
                  icon: const Icon(Icons.save_alt),
                  onPressed: () async {
                    final text = result.transcript ?? '';
                    final name = p.setExtension(p.basename(result.inputFile), '.txt');
                    final bytes = utf8.encode(text);
                    await FilePicker.platform.saveFile(fileName: name, bytes: bytes);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 8, children: [
              _Chip(label: 'Status', value: result.status.name),
              _Chip(label: 'Words', value: result.wordCount.toString()),
              _Chip(label: 'Duration', value: WhisperFormatters.duration(result.duration)),
              _Chip(label: 'Elapsed', value: WhisperFormatters.duration(result.processingTime)),
            ]),
            const SizedBox(height: 12),
            Divider(color: Theme.of(context).dividerColor.withOpacity(0.4)),
            const SizedBox(height: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      result.transcript ?? '(no transcript) ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace', height: 1.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
