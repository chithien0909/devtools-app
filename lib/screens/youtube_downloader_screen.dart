import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/video_info.dart' as models;
import '../services/youtube_service.dart';
import '../providers/youtube_provider.dart';
import '../providers/auto_installer_provider.dart';
import '../widgets/dependency_installer_widgets.dart';

class YouTubeDownloaderScreen extends ConsumerStatefulWidget {
  const YouTubeDownloaderScreen({super.key});

  @override
  ConsumerState<YouTubeDownloaderScreen> createState() => _YouTubeDownloaderScreenState();
}

class _YouTubeDownloaderScreenState extends ConsumerState<YouTubeDownloaderScreen> {
  late TextEditingController _urlController;
  
  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String url) {
    ref.read(urlInputProvider.notifier).state = url;
    ref.read(videoMetadataProvider.notifier).fetchMetadata(url);
  }

  Future<void> _selectOutputDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      ref.read(outputDirectoryProvider.notifier).state = result;
    }
  }

  void _startDownload() {
    final url = ref.read(urlInputProvider);
    final outputDir = ref.read(outputDirectoryProvider);
    final format = ref.read(selectedFormatProvider);
    final downloadSubtitles = ref.read(downloadSubtitlesProvider);

    ref.read(downloadStateProvider.notifier).startDownload(
      url,
      outputDir,
      format,
      downloadSubtitles: downloadSubtitles,
    );
  }

  void _openOutputFolder() async {
    final outputDir = ref.read(outputDirectoryProvider);
    if (outputDir.isNotEmpty) {
      final uri = Uri.file(outputDir);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ytDlpStatus = ref.watch(ytDlpInstallationStatusProvider);
    final videoMetadata = ref.watch(videoMetadataProvider);
    final downloadState = ref.watch(downloadStateProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Dependency status banner
        const DependencyStatusBanner(),
        
        const SizedBox(height: 16),
        
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // URL Input
                _buildUrlInput(),
                
                const SizedBox(height: 16),
                
                // Video Metadata
                videoMetadata.when(
                  data: (video) => video != null 
                      ? _buildVideoPreview(video)
                      : const SizedBox.shrink(),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => _buildErrorCard(error.toString()),
                ),
                
                const SizedBox(height: 16),
                
                // Download Options
                _buildDownloadOptions(),
                
                const SizedBox(height: 16),
                
                // Output Directory
                _buildOutputDirectorySelector(),
                
                const SizedBox(height: 16),
                
                // Download Progress
                if (downloadState.progress != null)
                  _buildDownloadProgress(downloadState.progress!),
                
                if (downloadState.error != null)
                  _buildErrorCard(downloadState.error!),
                  
                if (downloadState.result != null)
                  _buildDownloadResult(downloadState.result!),
                
                const SizedBox(height: 16),
                
                // Action Buttons
                _buildActionButtons(downloadState),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallationWarning() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'yt-dlp not found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Please install yt-dlp: pip install yt-dlp'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrlInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YouTube URL',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'Paste YouTube video URL here...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: _onUrlChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview(models.VideoInfo video) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: 120,
                height: 90,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 120,
                  height: 90,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.video_library),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 120,
                  height: 90,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Video Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.channel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        YoutubeService().formatDuration(video.duration),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        YoutubeService().formatViewCount(video.viewCount),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (video.hasSubtitles == true) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.subtitles, size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'Subtitles available',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<models.DownloadFormat>(
              value: ref.watch(selectedFormatProvider),
              decoration: const InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(),
              ),
              items: models.DownloadFormat.values.map((format) {
                return DropdownMenuItem(
                  value: format,
                  child: Text(format.label),
                );
              }).toList(),
              onChanged: (format) {
                if (format != null) {
                  ref.read(selectedFormatProvider.notifier).state = format;
                }
              },
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Download subtitles'),
              subtitle: const Text('Download available subtitles if any'),
              value: ref.watch(downloadSubtitlesProvider),
              onChanged: (value) {
                ref.read(downloadSubtitlesProvider.notifier).state = value ?? false;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputDirectorySelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Output Directory',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ref.watch(outputDirectoryProvider).isEmpty
                        ? 'No directory selected'
                        : ref.watch(outputDirectoryProvider),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _selectOutputDirectory,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadProgress(models.DownloadProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Download Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.percentage / 100,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${progress.percentage.toStringAsFixed(1)}%'),
                Text(progress.status),
              ],
            ),
            if (progress.speed != null || progress.eta != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (progress.speed != null) Text('Speed: ${progress.speed}'),
                  if (progress.eta != null) Text('ETA: ${progress.eta}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadResult(models.DownloadResult result) {
    return result.when(
      success: (filePath, fileName, fileSize) => Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Text(
                    'Download Complete',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('File: $fileName'),
              Text('Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB'),
              Text('Location: $filePath'),
            ],
          ),
        ),
      ),
      error: (message, details) => _buildErrorCard('$message${details != null ? '\n$details' : ''}'),
      cancelled: () => Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.cancel, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              Text(
                'Download Cancelled',
                style: TextStyle(color: Colors.orange.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(DownloadState downloadState) {
    final url = ref.watch(urlInputProvider);
    final outputDir = ref.watch(outputDirectoryProvider);
    final canDownload = url.isNotEmpty && outputDir.isNotEmpty && !downloadState.isDownloading;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canDownload ? _startDownload : null,
            icon: downloadState.isDownloading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(downloadState.isDownloading ? 'Downloading...' : 'Start Download'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (downloadState.isDownloading)
          ElevatedButton.icon(
            onPressed: () => ref.read(downloadStateProvider.notifier).cancelDownload(),
            icon: const Icon(Icons.stop),
            label: const Text('Cancel'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          )
        else if (outputDir.isNotEmpty)
          ElevatedButton.icon(
            onPressed: _openOutputFolder,
            icon: const Icon(Icons.folder_open),
            label: const Text('Open Folder'),
          ),
      ],
    );
  }
}