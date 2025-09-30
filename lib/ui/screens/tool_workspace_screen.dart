import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../data/models/developer_tool.dart';
import '../../viewmodels/tool_selector_view_model.dart';
import '../../services/pdf_service.dart';
import '../../services/image_processor_service.dart';
import '../../services/data_tools_service.dart';

const DataToolsService _dataToolsService = DataToolsService();

class ToolWorkspaceScreen extends StatelessWidget {
  const ToolWorkspaceScreen({super.key, required this.tool});

  final DeveloperTool tool;

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolSelectorViewModel>(
      builder: (context, viewModel, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final session = viewModel.sessionFor(tool.id);
        final operation = tool.operations[session.activeOperationIndex];
        final isQrScan = operation.id == 'qr_scan';
        final isQrGenerate = operation.id == 'qr_generate';
        final canRun = operation.isImplemented && !session.isProcessing;

        return Scaffold(
          body: Stack(
            children: [
              Hero(
                tag: 'tool-${tool.id}-background',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tool.primaryColor, tool.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _WorkspaceAppBar(tool: tool),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OperationSelector(
                              tool: tool,
                              activeIndex: session.activeOperationIndex,
                              onChanged: (index) =>
                                  viewModel.selectOperation(tool.id, index),
                            ),
                            const SizedBox(height: 16),
                            if (operation.id == 'api_tester')
                              const _ApiTesterPanel()
                            else if (operation.id == 'image_to_pdf')
                              _ImageToPdfPanel(
                                toolId: tool.id,
                                viewModel: viewModel,
                                session: session,
                              )
                            else if (operation.id == 'image_compressor')
                              _ImageCompressorPanel(
                                toolId: tool.id,
                                viewModel: viewModel,
                                session: session,
                              )
                            else if (operation.id == 'yaml_json')
                              _YamlJsonPanel(
                                toolId: tool.id,
                                viewModel: viewModel,
                                session: session,
                              )
                            else if (operation.id == 'text_case')
                              _TextCasePanel(
                                toolId: tool.id,
                                viewModel: viewModel,
                                session: session,
                              )
                            else if (operation.id == 'text_counter')
                              _TextCounterPanel(
                                toolId: tool.id,
                                viewModel: viewModel,
                                session: session,
                              )
                            else if (operation.id == 'regex_tester')
                              _RegexTesterPanel(
                                toolId: tool.id,
                                viewModel: viewModel,
                                session: session,
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionTitle(
                                    icon: operation.icon,
                                    title: operation.label,
                                    subtitle: operation.description,
                                  ),
                                  const SizedBox(height: 16),
                                  if (isQrScan)
                                    _QrScannerPanel(
                                      toolId: tool.id,
                                      viewModel: viewModel,
                                      session: session,
                                    )
                                  else ...[
                                    _InputField(
                                      controller: session.inputController,
                                      hint: operation.placeholder,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: canRun
                                                ? () => viewModel
                                                      .runCurrentOperation(
                                                        tool.id,
                                                      )
                                                : null,
                                            icon: session.isProcessing
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: colorScheme
                                                              .onPrimary,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.play_arrow_rounded,
                                                  ),
                                            label: Text(
                                              session.isProcessing
                                                  ? 'Processing...'
                                                  : operation.isImplemented
                                                  ? 'Run ${operation.label}'
                                                  : 'Planned feature',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton.filledTonal(
                                          tooltip: 'Use result as input',
                                          onPressed: session.output.isEmpty
                                              ? null
                                              : () => viewModel
                                                    .moveOutputToInput(tool.id),
                                          icon: const Icon(
                                            Icons.flip_camera_android_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!operation.isImplemented) ...[
                                      const SizedBox(height: 12),
                                      _InfoBanner(
                                        message:
                                            'This utility is on the DevTools+ roadmap. Check the roadmap tab for delivery updates.',
                                      ),
                                    ],
                                  ],
                                  const SizedBox(height: 12),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: session.error == null
                                        ? const SizedBox.shrink()
                                        : _ErrorBanner(message: session.error!),
                                  ),
                                  const SizedBox(height: 16),
                                  _SectionTitle(
                                    icon: Icons.outbox_outlined,
                                    title: 'Output',
                                    subtitle:
                                        'Result updates as soon as processing completes.',
                                  ),
                                  const SizedBox(height: 12),
                                  _OutputPanel(
                                    content: session.output,
                                    preview:
                                        isQrGenerate &&
                                            session.output.isNotEmpty
                                        ? Center(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color:
                                                    theme.colorScheme.surface,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: theme
                                                        .colorScheme
                                                        .shadow
                                                        .withValues(
                                                          alpha: 0.08,
                                                        ),
                                                    blurRadius: 18,
                                                    offset: const Offset(0, 10),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                child: QrImageView(
                                                  data: session.output,
                                                  version: QrVersions.auto,
                                                  size: 220,
                                                  backgroundColor: Colors.white,
                                                  eyeStyle: QrEyeStyle(
                                                    eyeShape: QrEyeShape.circle,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  dataModuleStyle:
                                                      QrDataModuleStyle(
                                                        dataModuleShape:
                                                            QrDataModuleShape
                                                                .circle,
                                                        color: theme
                                                            .colorScheme
                                                            .onPrimaryContainer,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : null,
                                    onCopy: session.output.isEmpty
                                        ? null
                                        : () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: session.output,
                                              ),
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      'Copied to clipboard',
                                                    ),
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                );
                                            }
                                          },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ImageCompressorPanel extends StatefulWidget {
  const _ImageCompressorPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_ImageCompressorPanel> createState() => _ImageCompressorPanelState();
}

class _ProcessedPreview {
  _ProcessedPreview({required this.file});

  final ProcessedImageFile file;
}

class _ImageCompressorPanelState extends State<_ImageCompressorPanel> {
  final ImageProcessorService _imageService = const ImageProcessorService();
  final List<_ImageItem> _images = [];
  final List<_ProcessedPreview> _processed = [];
  ProcessedPdfFile? _pdfFile;
  Uint8List? _archiveBytes;

  double _quality = 80;
  ResizeMode _resizeMode = ResizeMode.none;
  double _resizePercentage = 100;
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  bool _maintainAspect = true;
  ImageOutputFormat _outputFormat = ImageOutputFormat.jpeg;
  bool _keepMetadata = true;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null) {
        return;
      }
      final additions = <_ImageItem>[];
      for (final file in result.files) {
        final item = await _createImageItem(file);
        if (item != null) {
          additions.add(item);
        }
      }
      if (additions.isEmpty) {
        _setError('Unable to read the selected images.');
        return;
      }
      setState(() {
        _errorMessage = null;
        _processed.clear();
        _pdfFile = null;
        _archiveBytes = null;
        _images.addAll(additions);
      });
      widget.viewModel.setSessionState(widget.toolId, clearError: true);
    } catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> _loadSampleImages() async {
    const colors = [
      Color(0xFF5E35B1),
      Color(0xFF00897B),
      Color(0xFFD81B60),
      Color(0xFFFF7043),
    ];
    final samples = <_ImageItem>[];
    for (var i = 0; i < colors.length; i++) {
      samples.add(await _createSampleImage('Sample ${i + 1}', colors[i]));
    }
    setState(() {
      _errorMessage = null;
      _processed.clear();
      _pdfFile = null;
      _archiveBytes = null;
      _images
        ..clear()
        ..addAll(samples);
    });
    widget.viewModel.setSessionState(widget.toolId, clearError: true);
  }

  Future<_ImageItem?> _createImageItem(PlatformFile file) async {
    try {
      Uint8List? data = file.bytes;
      if (data == null) {
        final path = file.path;
        if (path == null) {
          return null;
        }
        data = await File(path).readAsBytes();
      }
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      return _ImageItem(
        bytes: data,
        name: file.name,
        width: frame.image.width,
        height: frame.image.height,
      );
    } catch (_) {
      return null;
    }
  }

  Future<_ImageItem> _createSampleImage(String label, Color color) async {
    const width = 960;
    const height = 640;
    final recorder = ui.PictureRecorder();
    final rect = ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final canvas = ui.Canvas(recorder, rect);
    canvas.drawRect(rect, Paint()..color = color);
    final paragraphBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: ui.TextAlign.center,
              fontSize: 54,
              fontFamily: 'Roboto',
            ),
          )
          ..pushStyle(ui.TextStyle(color: const ui.Color(0xFFFFFFFF)))
          ..addText(label);
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    canvas.drawParagraph(
      paragraph,
      ui.Offset(
        (width - paragraph.longestLine) / 2,
        (height - paragraph.height) / 2,
      ),
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return _ImageItem(
      bytes: bytes!.buffer.asUint8List(),
      name: '${label.toLowerCase().replaceAll(' ', '_')}.png',
      width: image.width,
      height: image.height,
    );
  }

  Future<void> _processImages() async {
    if (_images.isEmpty) {
      _setError('Add images to compress first.');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final inputs = _images
          .map(
            (image) => ImageProcessingInput(
              bytes: image.bytes,
              originalName: image.name,
            ),
          )
          .toList();

      final options = ImageProcessingOptions(
        outputFormat: _outputFormat,
        resizeMode: _resizeMode,
        quality: _quality.round(),
        resizePercentage: _resizePercentage,
        targetWidth: int.tryParse(_widthController.text.trim()),
        targetHeight: int.tryParse(_heightController.text.trim()),
        maintainAspectRatio: _maintainAspect,
        keepMetadata: _keepMetadata,
      );

      final result = await _imageService.process(inputs, options);

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
        _processed
          ..clear()
          ..addAll(result.files.map((file) => _ProcessedPreview(file: file)));
        _pdfFile = result.pdfFile;
        _archiveBytes = result.archiveBytes;
      });

      final summary = _pdfFile != null
          ? 'Generated PDF with ${_images.length} page(s).'
          : 'Processed ${_processed.length} image(s).';
      widget.viewModel.setSessionState(
        widget.toolId,
        output: summary,
        clearError: true,
      );
    } on ImageProcessingException catch (error) {
      _setError(error.message);
    } catch (error) {
      _setError(error.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveAll() async {
    if (_processed.isEmpty && _pdfFile == null) {
      _setError('Process the images before saving.');
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final targetDir = Directory(
      p.join(directory.path, 'image_compressor_$timestamp'),
    );
    await targetDir.create(recursive: true);

    if (_pdfFile != null) {
      final pdfPath = p.join(targetDir.path, _pdfFile!.fileName);
      await File(pdfPath).writeAsBytes(_pdfFile!.bytes, flush: true);
    }

    for (final item in _processed) {
      final path = p.join(targetDir.path, item.file.fileName);
      await File(path).writeAsBytes(item.file.bytes, flush: true);
    }

    if (_archiveBytes != null) {
      final archivePath = p.join(targetDir.path, 'batch_download.zip');
      await File(archivePath).writeAsBytes(_archiveBytes!, flush: true);
    }

    if (!mounted) {
      return;
    }

    widget.viewModel.setSessionState(
      widget.toolId,
      output: 'Saved to ${targetDir.path}',
      clearError: true,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Files saved to ${targetDir.path}')),
      );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  void _setError(String message) {
    setState(() => _errorMessage = message);
    widget.viewModel.setSessionState(
      widget.toolId,
      error: message,
      output: '',
      clearError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isCompact = maxWidth < 900;
        final tileWidth = isCompact ? (maxWidth - 24) / 2 : 180.0;
        final previewHeight = isCompact ? 320.0 : 440.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Select images'),
                ),
                OutlinedButton.icon(
                  onPressed: _loadSampleImages,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Load sample images'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _images.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      'Selected images will appear here. Add some to get started.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ReorderableWrap(
                    spacing: 12,
                    runSpacing: 12,
                    onReorder: _reorderImages,
                    needsLongPressDraggable: false,
                    children: [
                      for (var i = 0; i < _images.length; i++)
                        SizedBox(
                          width: tileWidth,
                          child: _ImagePreviewTile(
                            key: ValueKey('${_images[i].name}-$i'),
                            image: _images[i],
                            width: tileWidth,
                            onRemove: () => _removeImage(i),
                          ),
                        ),
                    ],
                  ),
            const SizedBox(height: 24),
            _buildControls(theme, isCompact),
            const SizedBox(height: 16),
            Flex(
              direction: isCompact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: _isProcessing ? null : _processImages,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    _isProcessing ? 'Processing...' : 'Process images',
                  ),
                ),
                SizedBox(width: isCompact ? 0 : 12, height: isCompact ? 12 : 0),
                FilledButton.tonalIcon(
                  onPressed: _isProcessing ? null : _saveAll,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Save all'),
                ),
                if (_archiveBytes != null) ...[
                  SizedBox(
                    width: isCompact ? 0 : 12,
                    height: isCompact ? 12 : 0,
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final tempDir = await getTemporaryDirectory();
                      final tempPath = p.join(
                        tempDir.path,
                        'image_batch_${DateTime.now().millisecondsSinceEpoch}.zip',
                      );
                      await File(
                        tempPath,
                      ).writeAsBytes(_archiveBytes!, flush: true);
                      if (!mounted) return;
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text('ZIP saved to $tempPath')),
                        );
                    },
                    icon: const Icon(Icons.archive_outlined),
                    label: const Text('Save ZIP'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null)
              _ErrorBanner(message: _errorMessage!)
            else if (_pdfFile != null) ...[
              _InfoBanner(message: 'PDF ready (${_images.length} page(s)).'),
              const SizedBox(height: 12),
              SizedBox(
                height: previewHeight,
                child: PdfPreview(
                  build: (format) async => _pdfFile!.bytes,
                  allowPrinting: true,
                  allowSharing: true,
                  canChangePageFormat: false,
                  pdfFileName: _pdfFile!.fileName,
                ),
              ),
            ] else if (_processed.isNotEmpty) ...[
              Text(
                'Preview (${_processed.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _processed
                    .map(
                      (item) => _ProcessedPreviewTile(
                        preview: item,
                        width: tileWidth,
                        height: previewHeight / 2,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildControls(ThemeData theme, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Compression & format', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: isCompact ? double.infinity : 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quality', style: theme.textTheme.labelLarge),
                      Text(
                        '${_quality.round()}%',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Slider(
                    value: _quality,
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '${_quality.round()}%',
                    onChanged: (value) => setState(() => _quality = value),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: isCompact ? double.infinity : 260,
              child: SegmentedButton<ResizeMode>(
                segments: const [
                  ButtonSegment(
                    value: ResizeMode.none,
                    label: Text('Original size'),
                    icon: Icon(Icons.fullscreen_exit),
                  ),
                  ButtonSegment(
                    value: ResizeMode.percentage,
                    label: Text('Percentage'),
                    icon: Icon(Icons.percent),
                  ),
                  ButtonSegment(
                    value: ResizeMode.custom,
                    label: Text('Custom'),
                    icon: Icon(Icons.photo_size_select_large),
                  ),
                ],
                selected: {_resizeMode},
                onSelectionChanged: (selection) =>
                    setState(() => _resizeMode = selection.first),
              ),
            ),
            if (_resizeMode == ResizeMode.percentage)
              SizedBox(
                width: isCompact ? double.infinity : 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Scale', style: theme.textTheme.labelLarge),
                        Text(
                          '${_resizePercentage.round()}%',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Slider(
                      value: _resizePercentage,
                      min: 1,
                      max: 400,
                      divisions: 399,
                      label: '${_resizePercentage.round()}%',
                      onChanged: (value) =>
                          setState(() => _resizePercentage = value),
                    ),
                  ],
                ),
              ),
            if (_resizeMode == ResizeMode.custom)
              SizedBox(
                width: isCompact ? double.infinity : 320,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _widthController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Width (px)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: false,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Height (px)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SwitchListTile.adaptive(
              value: _maintainAspect,
              onChanged: (value) => setState(() => _maintainAspect = value),
              title: const Text('Maintain aspect ratio'),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(
              width: isCompact ? double.infinity : 240,
              child: DropdownMenu<ImageOutputFormat>(
                label: const Text('Output format'),
                initialSelection: _outputFormat,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: ImageOutputFormat.jpeg,
                    label: 'JPEG',
                  ),
                  DropdownMenuEntry(value: ImageOutputFormat.png, label: 'PNG'),
                  DropdownMenuEntry(
                    value: ImageOutputFormat.webp,
                    label: 'WebP',
                  ),
                  DropdownMenuEntry(
                    value: ImageOutputFormat.pdf,
                    label: 'PDF (multi-page)',
                  ),
                ],
                onSelected: (value) => setState(
                  () => _outputFormat = value ?? ImageOutputFormat.jpeg,
                ),
              ),
            ),
            SwitchListTile.adaptive(
              value: _keepMetadata,
              onChanged: (value) => setState(() => _keepMetadata = value),
              title: const Text('Keep EXIF metadata'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProcessedPreviewTile extends StatelessWidget {
  const _ProcessedPreviewTile({
    required this.preview,
    required this.width,
    required this.height,
  });

  final _ProcessedPreview preview;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      constraints: BoxConstraints(maxWidth: width, minHeight: height / 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Image.memory(preview.file.bytes, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  preview.file.fileName,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${preview.file.width}×${preview.file.height}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _YamlJsonMode { yamlToJson, jsonToYaml }

class _YamlJsonPanel extends StatefulWidget {
  const _YamlJsonPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_YamlJsonPanel> createState() => _YamlJsonPanelState();
}

class _YamlJsonPanelState extends State<_YamlJsonPanel> {
  _YamlJsonMode _mode = _YamlJsonMode.yamlToJson;
  bool _autoDetect = true;

  Future<void> _convert() async {
    final input = widget.session.inputController.text.trim();
    if (input.isEmpty) {
      widget.viewModel.setSessionState(
        widget.toolId,
        error: 'Provide YAML or JSON to convert.',
        output: '',
        clearError: false,
      );
      return;
    }
    try {
      final mode = _autoDetect ? _detectMode(input) : _mode;
      final result = mode == _YamlJsonMode.yamlToJson
          ? await _dataToolsService.yamlToJson(input)
          : await _dataToolsService.jsonToYaml(input);
      widget.viewModel.setSessionState(
        widget.toolId,
        output: result,
        clearError: true,
      );
    } catch (error) {
      widget.viewModel.setSessionState(
        widget.toolId,
        error: error.toString(),
        output: '',
        clearError: false,
      );
    }
  }

  _YamlJsonMode _detectMode(String input) {
    final trimmed = input.trimLeft();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return _YamlJsonMode.jsonToYaml;
    }
    return _YamlJsonMode.yamlToJson;
  }

  @override
  Widget build(BuildContext context) {
    final mode = _autoDetect
        ? _detectMode(widget.session.inputController.text)
        : _mode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SegmentedButton<_YamlJsonMode>(
              segments: const [
                ButtonSegment(
                  value: _YamlJsonMode.yamlToJson,
                  label: Text('YAML → JSON'),
                ),
                ButtonSegment(
                  value: _YamlJsonMode.jsonToYaml,
                  label: Text('JSON → YAML'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: _autoDetect
                  ? null
                  : (selection) => setState(() => _mode = selection.first),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: _autoDetect,
              onChanged: (value) => setState(() => _autoDetect = value ?? true),
            ),
            const Text('Auto-detect'),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.session.inputController,
          minLines: 8,
          maxLines: null,
          decoration: InputDecoration(
            labelText:
                'Input (${mode == _YamlJsonMode.yamlToJson ? 'YAML' : 'JSON'})',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _convert,
          icon: const Icon(Icons.swap_horiz_outlined),
          label: Text(
            mode == _YamlJsonMode.yamlToJson
                ? 'Convert to JSON'
                : 'Convert to YAML',
          ),
        ),
      ],
    );
  }
}

class _TextCasePanel extends StatefulWidget {
  const _TextCasePanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_TextCasePanel> createState() => _TextCasePanelState();
}

class _TextCasePanelState extends State<_TextCasePanel> {
  TextCase _selectedCase = TextCase.camel;
  bool _liveUpdate = true;

  @override
  void initState() {
    super.initState();
    widget.session.inputController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.session.inputController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_liveUpdate) {
      _convert();
    }
  }

  void _convert() {
    final input = widget.session.inputController.text;
    final output = _dataToolsService.convertTextCase(input, _selectedCase);
    widget.viewModel.setSessionState(
      widget.toolId,
      output: output,
      clearError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownMenu<TextCase>(
          initialSelection: _selectedCase,
          label: const Text('Target case'),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: TextCase.camel, label: 'camelCase'),
            DropdownMenuEntry(value: TextCase.pascal, label: 'PascalCase'),
            DropdownMenuEntry(value: TextCase.snake, label: 'snake_case'),
            DropdownMenuEntry(value: TextCase.kebab, label: 'kebab-case'),
            DropdownMenuEntry(value: TextCase.title, label: 'Title Case'),
            DropdownMenuEntry(value: TextCase.upper, label: 'UPPER CASE'),
            DropdownMenuEntry(value: TextCase.lower, label: 'lower case'),
          ],
          onSelected: (value) {
            if (value == null) return;
            setState(() => _selectedCase = value);
            _convert();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Switch(
              value: _liveUpdate,
              onChanged: (value) {
                setState(() => _liveUpdate = value);
                if (value) {
                  _convert();
                }
              },
            ),
            const Text('Apply while typing'),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.session.inputController,
          minLines: 6,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Input text',
            alignLabelWithHint: true,
          ),
        ),
        if (!_liveUpdate) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.text_fields_outlined),
            label: const Text('Convert text'),
          ),
        ],
      ],
    );
  }
}

class _TextCounterPanel extends StatefulWidget {
  const _TextCounterPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_TextCounterPanel> createState() => _TextCounterPanelState();
}

class _TextCounterPanelState extends State<_TextCounterPanel> {
  Map<String, Object?> _stats = const {};

  void _compute() {
    final input = widget.session.inputController.text;
    final stats = _dataToolsService.textStats(input);
    setState(() => _stats = stats);
    widget.viewModel.setSessionState(
      widget.toolId,
      output: const JsonEncoder.withIndent('  ').convert(stats),
      clearError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.session.inputController,
          minLines: 6,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Paste text to analyze',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _compute,
          icon: const Icon(Icons.analytics_outlined),
          label: const Text('Count'),
        ),
        const SizedBox(height: 12),
        if (_stats.isNotEmpty)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _stats.entries
                .map(
                  (entry) => Chip(
                    avatar: const Icon(Icons.data_usage_outlined, size: 16),
                    label: Text('${entry.key}: ${entry.value}'),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _RegexTesterPanel extends StatefulWidget {
  const _RegexTesterPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_RegexTesterPanel> createState() => _RegexTesterPanelState();
}

class _RegexTesterPanelState extends State<_RegexTesterPanel> {
  final TextEditingController _patternController = TextEditingController();
  bool _multiLine = true;
  bool _caseSensitive = true;
  RegExpResult? _result;

  @override
  void dispose() {
    _patternController.dispose();
    super.dispose();
  }

  void _run() {
    final pattern = _patternController.text;
    final input = widget.session.inputController.text;
    if (pattern.isEmpty) {
      widget.viewModel.setSessionState(
        widget.toolId,
        error: 'Enter a regex pattern to test.',
        output: '',
        clearError: false,
      );
      return;
    }
    final result = _dataToolsService.testRegex(
      pattern,
      input,
      multiLine: _multiLine,
      caseSensitive: _caseSensitive,
    );
    setState(() => _result = result);
    final summary = result.hasError
        ? 'Error: ${result.errorMessage}'
        : 'Matches found: ${result.matches.length}';
    widget.viewModel.setSessionState(
      widget.toolId,
      output: summary,
      clearError: !result.hasError,
      error: result.hasError ? summary : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _patternController,
          decoration: const InputDecoration(
            labelText: 'Regex pattern',
            prefixIcon: Icon(Icons.pattern),
          ),
          onSubmitted: (_) => _run(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Switch(
              value: _multiLine,
              onChanged: (value) => setState(() => _multiLine = value),
            ),
            const Text('Multiline'),
            const SizedBox(width: 16),
            Switch(
              value: _caseSensitive,
              onChanged: (value) => setState(() => _caseSensitive = value),
            ),
            const Text('Case sensitive'),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: widget.session.inputController,
          minLines: 6,
          maxLines: null,
          decoration: const InputDecoration(
            labelText: 'Test text',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _run,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Run regex'),
        ),
        const SizedBox(height: 12),
        if (result != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: result.hasError
                  ? Text(
                      result.errorMessage ?? 'Invalid expression',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    )
                  : _RegexPreview(
                      input: widget.session.inputController.text,
                      matches: result.matches,
                    ),
            ),
          ),
      ],
    );
  }
}

class _RegexPreview extends StatelessWidget {
  const _RegexPreview({required this.input, required this.matches});

  final String input;
  final List<RegexMatchDetail> matches;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return Text(
        'No matches found.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }
    final spans = <TextSpan>[];
    int index = 0;
    for (final match in matches) {
      if (match.start > index) {
        spans.add(TextSpan(text: input.substring(index, match.start)));
      }
      spans.add(
        TextSpan(
          text: input.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.secondary.withOpacity(0.3),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      index = match.end;
    }
    if (index < input.length) {
      spans.add(TextSpan(text: input.substring(index)));
    }
    return SelectableText.rich(TextSpan(children: spans));
  }
}

class _WorkspaceAppBar extends StatelessWidget {
  const _WorkspaceAppBar({required this.tool});

  final DeveloperTool tool;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: colorScheme.onPrimary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tool.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool.tagline,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'All tools',
          onPressed: () {
            context.read<ToolSelectorViewModel>().selectCategory(null);
            Navigator.of(context).maybePop();
          },
          icon: Icon(
            Icons.grid_view_rounded,
            color: colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
        Icon(tool.icon, color: colorScheme.onPrimary.withValues(alpha: 0.75)),
      ],
    );
  }
}

class _OperationSelector extends StatelessWidget {
  const _OperationSelector({
    required this.tool,
    required this.activeIndex,
    required this.onChanged,
  });

  final DeveloperTool tool;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          for (var index = 0; index < tool.operations.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                selected: index == activeIndex,
                onSelected: (_) => onChanged(index),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                pressElevation: 0,
                avatar: Icon(
                  tool.operations[index].icon,
                  size: 16,
                  color: index == activeIndex
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                ),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    tool.operations[index].label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                labelStyle: theme.textTheme.bodySmall,
                selectedColor: colorScheme.primary,
                backgroundColor: theme.cardColor,
                shape: StadiumBorder(
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, this.hint});

  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 6,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint ?? 'Paste or type your content here...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
      ),
    );
  }
}

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({
    required this.content,
    required this.onCopy,
    this.preview,
  });

  final String content;
  final VoidCallback? onCopy;
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = content.isNotEmpty;
    final hasPreview = preview != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Processed output',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Copy result',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasContent && !hasPreview)
            Text(
              'Run the tool to see the transformation here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            if (hasPreview) ...[
              preview!,
              if (hasContent) const SizedBox(height: 16),
            ],
            if (hasContent)
              SelectableText(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Roboto Mono',
                ),
              ),
          ],
        ],
      ),
    );
  }
}

enum _RequestBodyMode { raw, formData }

class _EditablePair {
  _EditablePair({String key = '', String value = ''})
    : keyController = TextEditingController(text: key),
      valueController = TextEditingController(text: value);

  final TextEditingController keyController;
  final TextEditingController valueController;

  MapEntry<String, String> toEntry() =>
      MapEntry(keyController.text.trim(), valueController.text.trim());

  bool get hasData =>
      keyController.text.trim().isNotEmpty &&
      valueController.text.trim().isNotEmpty;

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class _ApiRequestSnapshot {
  const _ApiRequestSnapshot({
    required this.method,
    required this.url,
    required this.headers,
    required this.bodyMode,
    required this.rawBody,
    required this.formData,
  });

  final String method;
  final String url;
  final List<MapEntry<String, String>> headers;
  final _RequestBodyMode bodyMode;
  final String rawBody;
  final List<MapEntry<String, String>> formData;
}

class _ApiHistoryEntry {
  _ApiHistoryEntry({required this.snapshot, required this.savedAt});

  final _ApiRequestSnapshot snapshot;
  final DateTime savedAt;
}

class _ApiResponseData {
  const _ApiResponseData({
    required this.statusCode,
    required this.reasonPhrase,
    required this.elapsedMs,
    required this.sizeBytes,
    required this.headers,
    required this.body,
    this.parsedJson,
  });

  final int statusCode;
  final String? reasonPhrase;
  final int elapsedMs;
  final int sizeBytes;
  final Map<String, String> headers;
  final String body;
  final dynamic parsedJson;

  bool get isJson => parsedJson != null;
}

class _ImageItem {
  _ImageItem({
    required this.bytes,
    required this.name,
    required this.width,
    required this.height,
  });

  final Uint8List bytes;
  final String name;
  final int width;
  final int height;
}

enum _PageSizeOption { a4, letter, custom }

class _ImageToPdfPanel extends StatefulWidget {
  const _ImageToPdfPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_ImageToPdfPanel> createState() => _ImageToPdfPanelState();
}

class _ImageToPdfPanelState extends State<_ImageToPdfPanel> {
  final PdfService _pdfService = const PdfService();
  final List<_ImageItem> _images = [];
  final TextEditingController _minDimensionController = TextEditingController(
    text: '100',
  );
  final TextEditingController _fileNameController = TextEditingController(
    text: 'output.pdf',
  );
  final TextEditingController _watermarkController = TextEditingController();
  final TextEditingController _headerController = TextEditingController();
  final TextEditingController _footerController = TextEditingController();

  PdfLayoutMode _layout = PdfLayoutMode.vertical;
  PdfScalingMode _scaling = PdfScalingMode.fitToPage;
  _PageSizeOption _pageSize = _PageSizeOption.a4;
  double _customWidthMm = 210;
  double _customHeightMm = 297;
  double _marginMm = 15;
  bool _skipTiny = true;
  Uint8List? _pdfBytes;
  String? _savedPath;
  bool _isGenerating = false;
  String? _errorMessage;

  @override
  void dispose() {
    _minDimensionController.dispose();
    _fileNameController.dispose();
    _watermarkController.dispose();
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
        withData: true,
      );
      if (result == null) {
        return;
      }
      final additions = <_ImageItem>[];
      for (final file in result.files) {
        final item = await _createImageItem(file);
        if (item != null) {
          additions.add(item);
        }
      }
      if (additions.isEmpty) {
        _setError('No readable images were selected.');
        return;
      }
      setState(() {
        _errorMessage = null;
        _images.addAll(additions);
      });
      widget.viewModel.setSessionState(widget.toolId, clearError: true);
    } catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> _loadSampleImages() async {
    const colors = [
      Color(0xFFE63946),
      Color(0xFF457B9D),
      Color(0xFF2A9D8F),
      Color(0xFFF4A261),
    ];
    final samples = <_ImageItem>[];
    for (var i = 0; i < colors.length; i++) {
      samples.add(await _createSampleImage('Sample ${i + 1}', colors[i]));
    }
    setState(() {
      _errorMessage = null;
      _images
        ..clear()
        ..addAll(samples);
    });
    widget.viewModel.setSessionState(widget.toolId, clearError: true);
  }

  Future<_ImageItem?> _createImageItem(PlatformFile file) async {
    try {
      Uint8List? data = file.bytes;
      if (data == null) {
        final path = file.path;
        if (path == null) {
          return null;
        }
        data = await File(path).readAsBytes();
      }
      final dimensions = await _decodeSize(data);
      return _ImageItem(
        bytes: data,
        name: file.name,
        width: dimensions.width.round(),
        height: dimensions.height.round(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<_ImageItem> _createSampleImage(String label, Color color) async {
    const width = 800;
    const height = 600;
    final recorder = ui.PictureRecorder();
    final canvasRect = ui.Rect.fromLTWH(
      0,
      0,
      width.toDouble(),
      height.toDouble(),
    );
    final canvas = ui.Canvas(recorder, canvasRect);
    final paint = Paint()..color = color;
    canvas.drawRect(canvasRect, paint);
    final paragraphBuilder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: ui.TextAlign.center,
              fontSize: 56,
              fontFamily: 'Roboto',
            ),
          )
          ..pushStyle(ui.TextStyle(color: const ui.Color(0xFFFFFFFF)))
          ..addText(label);
    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));
    canvas.drawParagraph(
      paragraph,
      ui.Offset(
        (width - paragraph.longestLine) / 2,
        (height - paragraph.height) / 2,
      ),
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return _ImageItem(
      bytes: bytes,
      name: '${label.toLowerCase().replaceAll(' ', '_')}.png',
      width: img.width,
      height: img.height,
    );
  }

  Future<ui.Size> _decodeSize(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    return ui.Size(image.width.toDouble(), image.height.toDouble());
  }

  Future<void> _generatePdf() async {
    final threshold = double.tryParse(_minDimensionController.text) ?? 100;
    final filtered = _skipTiny
        ? _images
              .where(
                (image) =>
                    image.width >= threshold && image.height >= threshold,
              )
              .toList()
        : List<_ImageItem>.from(_images);

    if (filtered.isEmpty) {
      _setError('No images satisfy the minimum size requirement.');
      return;
    }

    final fileName = _fileNameController.text.trim().isEmpty
        ? 'output.pdf'
        : _fileNameController.text.trim();

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      final assets = filtered
          .map(
            (image) => PdfImageAsset(
              bytes: image.bytes,
              name: image.name,
              width: image.width,
              height: image.height,
            ),
          )
          .toList();

      final result = await _pdfService.generatePdf(
        images: assets,
        layout: _layout,
        pageFormat: _resolvePageFormat(),
        scaling: _scaling,
        margin: _mmToPt(_marginMm),
        watermark: _watermarkController.text.trim().isEmpty
            ? null
            : _watermarkController.text.trim(),
        headerText: _headerController.text.trim().isEmpty
            ? null
            : _headerController.text.trim(),
        footerText: _footerController.text.trim().isEmpty
            ? null
            : _footerController.text.trim(),
        fileName: fileName,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isGenerating = false;
        _pdfBytes = result.bytes;
        _savedPath = result.filePath;
      });

      widget.viewModel.setSessionState(
        widget.toolId,
        output: 'PDF saved to ${result.filePath}',
        clearError: true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isGenerating = false;
      });
      final message = error is PdfException ? error.message : error.toString();
      _setError(message);
    }
  }

  PdfPageFormat _resolvePageFormat() {
    switch (_pageSize) {
      case _PageSizeOption.a4:
        return PdfPageFormat.a4;
      case _PageSizeOption.letter:
        return PdfPageFormat.letter;
      case _PageSizeOption.custom:
        final double widthMm = _customWidthMm <= 0 ? 210.0 : _customWidthMm;
        final double heightMm = _customHeightMm <= 0 ? 297.0 : _customHeightMm;
        return PdfPageFormat(_mmToPt(widthMm), _mmToPt(heightMm));
    }
  }

  double _mmToPt(double value) => (value * PdfPageFormat.mm).toDouble();

  void _setError(String message) {
    setState(() => _errorMessage = message);
    widget.viewModel.setSessionState(
      widget.toolId,
      error: message,
      output: '',
      clearError: false,
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasPdf = _pdfBytes != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final isCompact = maxWidth < 840;
        final isVeryCompact = maxWidth < 520;
        final fieldWidth = isCompact ? maxWidth : 240.0;
        final tileWidth = isVeryCompact
            ? (maxWidth - 12).clamp(120.0, 220.0)
            : (isCompact ? (maxWidth - 36) / 2 : 160.0);
        final previewHeight = isVeryCompact
            ? 320.0
            : (isCompact ? 380.0 : 460.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Select images'),
                ),
                OutlinedButton.icon(
                  onPressed: _loadSampleImages,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Load sample images'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _images.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      'Selected images will appear here. Add some to get started.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : ReorderableWrap(
                    spacing: 12,
                    runSpacing: 12,
                    maxMainAxisCount: isVeryCompact ? 1 : null,
                    onReorder: _reorderImages,
                    needsLongPressDraggable: false,
                    children: [
                      for (var i = 0; i < _images.length; i++)
                        SizedBox(
                          width: tileWidth,
                          child: _ImagePreviewTile(
                            key: ValueKey('${_images[i].name}-$i'),
                            image: _images[i],
                            width: tileWidth,
                            onRemove: () => _removeImage(i),
                          ),
                        ),
                    ],
                  ),
            const SizedBox(height: 24),
            _buildOptionsGrid(theme, fieldWidth, isCompact),
            const SizedBox(height: 16),
            _buildAdvancedOptions(theme, fieldWidth, isCompact),
            const SizedBox(height: 16),
            Flex(
              direction: isVeryCompact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: isVeryCompact
                  ? CrossAxisAlignment.stretch
                  : CrossAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isGenerating ? null : _generatePdf,
                  icon: _isGenerating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(_isGenerating ? 'Generating...' : 'Generate PDF'),
                ),
                if (hasPdf) ...[
                  SizedBox(width: isVeryCompact ? 0 : 12, height: 12),
                  Align(
                    alignment: isVeryCompact
                        ? Alignment.centerRight
                        : Alignment.center,
                    child: IconButton.filledTonal(
                      tooltip: 'Share PDF',
                      onPressed: () => Printing.sharePdf(
                        bytes: _pdfBytes!,
                        filename: _fileNameController.text.trim().isEmpty
                            ? 'output.pdf'
                            : _fileNameController.text.trim(),
                      ),
                      icon: const Icon(Icons.ios_share_outlined),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null)
              _ErrorBanner(message: _errorMessage!)
            else if (hasPdf) ...[
              _InfoBanner(
                message: 'Saved to ${_savedPath ?? 'unknown location'}',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: previewHeight,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double height = constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : 420.0;
                    final double width = constraints.maxWidth.isFinite
                        ? constraints.maxWidth
                        : double.infinity;
                    return SizedBox(
                      height: height,
                      width: width,
                      child: PdfPreview(
                        build: (format) async => _pdfBytes!,
                        allowPrinting: true,
                        allowSharing: true,
                        canChangePageFormat: false,
                        pdfFileName: _fileNameController.text.trim().isEmpty
                            ? 'output.pdf'
                            : _fileNameController.text.trim(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildOptionsGrid(ThemeData theme, double fieldWidth, bool isCompact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Layout & filtering', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: fieldWidth,
              child: SegmentedButton<PdfLayoutMode>(
                segments: const [
                  ButtonSegment(
                    value: PdfLayoutMode.vertical,
                    label: Text('Vertical'),
                    icon: Icon(Icons.view_agenda_outlined),
                  ),
                  ButtonSegment(
                    value: PdfLayoutMode.horizontalGrid,
                    label: Text('Horizontal'),
                    icon: Icon(Icons.grid_view_outlined),
                  ),
                ],
                selected: {_layout},
                onSelectionChanged: (selection) =>
                    setState(() => _layout = selection.first),
              ),
            ),
            SizedBox(
              width: isCompact ? fieldWidth : 260,
              child: SegmentedButton<PdfScalingMode>(
                segments: const [
                  ButtonSegment(
                    value: PdfScalingMode.fitToPage,
                    label: Text('Fit to page'),
                    icon: Icon(Icons.fullscreen),
                  ),
                  ButtonSegment(
                    value: PdfScalingMode.originalSize,
                    label: Text('Original'),
                    icon: Icon(Icons.photo_size_select_large),
                  ),
                  ButtonSegment(
                    value: PdfScalingMode.stretch,
                    label: Text('Stretch'),
                    icon: Icon(Icons.aspect_ratio),
                  ),
                ],
                selected: {_scaling},
                onSelectionChanged: (selection) =>
                    setState(() => _scaling = selection.first),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: DropdownMenu<_PageSizeOption>(
                label: const Text('Page size'),
                initialSelection: _pageSize,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(
                    value: _PageSizeOption.a4,
                    label: 'A4 (210 × 297 mm)',
                  ),
                  DropdownMenuEntry(
                    value: _PageSizeOption.letter,
                    label: 'Letter (8.5 × 11 in)',
                  ),
                  DropdownMenuEntry(
                    value: _PageSizeOption.custom,
                    label: 'Custom',
                  ),
                ],
                onSelected: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _pageSize = value);
                },
              ),
            ),
            if (_pageSize == _PageSizeOption.custom)
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: fieldWidth * 1.5),
                child: Flex(
                  direction: isCompact ? Axis.vertical : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: isCompact ? double.infinity : fieldWidth * 0.7,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Width (mm)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) => setState(() {
                          _customWidthMm =
                              double.tryParse(value) ?? _customWidthMm;
                        }),
                      ),
                    ),
                    SizedBox(
                      width: isCompact ? 0 : 12,
                      height: isCompact ? 12 : 0,
                    ),
                    SizedBox(
                      width: isCompact ? double.infinity : fieldWidth * 0.7,
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Height (mm)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (value) => setState(() {
                          _customHeightMm =
                              double.tryParse(value) ?? _customHeightMm;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CheckboxListTile(
          value: _skipTiny,
          onChanged: (value) => setState(() => _skipTiny = value ?? true),
          title: const Text('Skip tiny images'),
          subtitle: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isCompact ? double.infinity : 220,
            ),
            child: TextField(
              controller: _minDimensionController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Minimum width/height (px)',
              ),
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions(
    ThemeData theme,
    double fieldWidth,
    bool isCompact,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Page & metadata', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: fieldWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Margins (mm)', style: theme.textTheme.labelLarge),
                  Slider(
                    value: _marginMm.clamp(0, 40).toDouble(),
                    min: 0,
                    max: 40,
                    divisions: 40,
                    label: _marginMm.toStringAsFixed(0),
                    onChanged: (value) => setState(() => _marginMm = value),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _fileNameController,
                decoration: const InputDecoration(
                  labelText: 'Output file name',
                ),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _watermarkController,
                decoration: const InputDecoration(
                  labelText: 'Watermark (optional)',
                ),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _headerController,
                decoration: const InputDecoration(
                  labelText: 'Header (optional)',
                ),
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: TextField(
                controller: _footerController,
                decoration: const InputDecoration(
                  labelText: 'Footer (optional)',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ImagePreviewTile extends StatelessWidget {
  const _ImagePreviewTile({
    super.key,
    required this.image,
    required this.width,
    required this.onRemove,
  });

  final _ImageItem image;
  final double width;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: Image.memory(image.bytes, fit: BoxFit.cover)),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove',
              onPressed: onRemove,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  '${image.width}×${image.height}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiTesterPanel extends StatefulWidget {
  const _ApiTesterPanel();

  @override
  State<_ApiTesterPanel> createState() => _ApiTesterPanelState();
}

class _ApiTesterPanelState extends State<_ApiTesterPanel> {
  static const _methods = <String>[
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS',
  ];

  String _method = 'GET';
  final _urlCtrl = TextEditingController(
    text: 'https://api.example.com/resource',
  );
  final _rawBodyCtrl = TextEditingController(text: '{\n  "key": "value"\n}');
  final List<_EditablePair> _headers = [
    _EditablePair(key: 'Content-Type', value: 'application/json'),
    _EditablePair(key: 'Accept', value: 'application/json'),
  ];
  final List<_EditablePair> _formFields = [_EditablePair()];
  _RequestBodyMode _bodyMode = _RequestBodyMode.raw;
  bool _isSending = false;
  String? _error;
  _ApiResponseData? _response;
  String? _curlCommand;
  _ApiRequestSnapshot? _latestSnapshot;
  final List<_ApiHistoryEntry> _history = [];

  bool get _methodAllowsBody => !{'GET', 'HEAD'}.contains(_method);

  @override
  void dispose() {
    _urlCtrl.dispose();
    _rawBodyCtrl.dispose();
    for (final header in _headers) {
      header.dispose();
    }
    for (final field in _formFields) {
      field.dispose();
    }
    super.dispose();
  }

  void _addHeader() {
    setState(() => _headers.add(_EditablePair()));
  }

  void _removeHeader(int index) {
    if (index >= 0 && index < _headers.length) {
      final removed = _headers.removeAt(index);
      removed.dispose();
      setState(() {});
    }
  }

  void _addFormField() {
    setState(() => _formFields.add(_EditablePair()));
  }

  void _removeFormField(int index) {
    if (index >= 0 && index < _formFields.length) {
      final removed = _formFields.removeAt(index);
      removed.dispose();
      setState(() {
        if (_formFields.isEmpty) {
          _formFields.add(_EditablePair());
        }
      });
    }
  }

  _EditablePair? _findHeaderPair(String name) {
    final lookup = name.toLowerCase();
    for (final pair in _headers) {
      if (pair.keyController.text.trim().toLowerCase() == lookup) {
        return pair;
      }
    }
    return null;
  }

  void _syncSuggestedContentType(_RequestBodyMode mode) {
    final target = mode == _RequestBodyMode.raw
        ? 'application/json'
        : 'application/x-www-form-urlencoded';
    final pair = _findHeaderPair('Content-Type');
    if (pair == null) {
      _headers.insert(0, _EditablePair(key: 'Content-Type', value: target));
      return;
    }
    final current = pair.valueController.text.trim().toLowerCase();
    if (current.isEmpty ||
        current == 'application/json' ||
        current == 'application/x-www-form-urlencoded') {
      pair.valueController.text = target;
    }
  }

  Map<String, String> _collectHeaders() {
    final headers = <String, String>{};
    for (final pair in _headers) {
      final entry = pair.toEntry();
      if (entry.key.isNotEmpty && entry.value.isNotEmpty) {
        headers[entry.key] = entry.value;
      }
    }

    if (_methodAllowsBody) {
      if (_bodyMode == _RequestBodyMode.raw) {
        headers.putIfAbsent('Content-Type', () => 'application/json');
      } else {
        headers.putIfAbsent(
          'Content-Type',
          () => 'application/x-www-form-urlencoded',
        );
      }
    }
    return headers;
  }

  List<MapEntry<String, String>> _collectFormData() {
    return _formFields
        .map((pair) => pair.toEntry())
        .where((entry) => entry.key.isNotEmpty)
        .toList();
  }

  Future<void> _send() async {
    final urlText = _urlCtrl.text.trim();
    if (urlText.isEmpty) {
      setState(() {
        _error = 'Provide a request URL to continue.';
        _response = null;
      });
      return;
    }

    Uri? uri;
    try {
      uri = Uri.parse(urlText);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$urlText');
      }
    } catch (_) {
      setState(() {
        _error =
            'Unable to parse the URL. Double-check the address and try again.';
        _response = null;
      });
      return;
    }

    final headers = _collectHeaders();
    final formData = _collectFormData();
    final rawBody = _rawBodyCtrl.text;
    _latestSnapshot = _ApiRequestSnapshot(
      method: _method,
      url: uri.toString(),
      headers: headers.entries.toList(),
      bodyMode: _bodyMode,
      rawBody: rawBody,
      formData: formData,
    );

    setState(() {
      _isSending = true;
      _error = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final request = http.Request(_method, uri);
      request.headers.addAll(headers);
      if (_methodAllowsBody) {
        if (_bodyMode == _RequestBodyMode.raw) {
          request.body = rawBody;
        } else {
          final fields = {for (final entry in formData) entry.key: entry.value};
          request.bodyFields = fields;
        }
      }

      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      client.close();

      dynamic parsedJson;
      try {
        if (response.body.isNotEmpty) {
          parsedJson = jsonDecode(response.body);
        }
      } catch (_) {
        parsedJson = null;
      }

      final responseHeaders = <String, String>{};
      response.headers.forEach((key, value) {
        responseHeaders[key] = value;
      });

      final data = _ApiResponseData(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        elapsedMs: stopwatch.elapsedMilliseconds,
        sizeBytes: response.bodyBytes.length,
        headers: responseHeaders,
        body: response.body,
        parsedJson: parsedJson,
      );

      if (mounted) {
        setState(() {
          _response = data;
          _error = null;
          _curlCommand = _buildCurlCommand(
            request.method,
            uri.toString(),
            headers,
            _methodAllowsBody
                ? (request.bodyBytes.isEmpty
                      ? rawBody
                      : utf8.decode(request.bodyBytes))
                : '',
          );
        });
      }
    } catch (error) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _response = null;
          _error = error.toString();
          _curlCommand = _buildCurlCommand(
            _method,
            uri?.toString() ?? urlText,
            headers,
            _methodAllowsBody ? rawBody : '',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _buildCurlCommand(
    String method,
    String url,
    Map<String, String> headers,
    String body,
  ) {
    final buffer = StringBuffer('curl -X $method');
    buffer.write(" '$url'");
    headers.forEach((key, value) {
      buffer.write(
        " -H '${_escapeSingleQuotes(key)}: ${_escapeSingleQuotes(value)}'",
      );
    });
    if (body.trim().isNotEmpty) {
      buffer.write(" -d '${_escapeSingleQuotes(body)}'");
    }
    return buffer.toString();
  }

  String _escapeSingleQuotes(String value) => value.replaceAll("'", "'\\''");

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _saveToHistory() {
    final snapshot = _latestSnapshot;
    if (snapshot == null) {
      return;
    }
    setState(() {
      _history.insert(
        0,
        _ApiHistoryEntry(snapshot: snapshot, savedAt: DateTime.now()),
      );
      if (_history.length > 10) {
        _history.removeLast();
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Saved to history')));
    }
  }

  void _applySnapshot(_ApiRequestSnapshot snapshot) {
    for (final header in _headers) {
      header.dispose();
    }
    for (final field in _formFields) {
      field.dispose();
    }

    setState(() {
      _method = snapshot.method;
      _urlCtrl.text = snapshot.url;
      _bodyMode = snapshot.bodyMode;
      _rawBodyCtrl.text = snapshot.rawBody;

      _headers
        ..clear()
        ..addAll(
          snapshot.headers.isEmpty
              ? [_EditablePair()]
              : snapshot.headers.map(
                  (entry) => _EditablePair(key: entry.key, value: entry.value),
                ),
        );

      _formFields
        ..clear()
        ..addAll(
          snapshot.formData.isEmpty
              ? [_EditablePair()]
              : snapshot.formData.map(
                  (entry) => _EditablePair(key: entry.key, value: entry.value),
                ),
        );
      _syncSuggestedContentType(_bodyMode);
    });
  }

  Widget _buildHeaderRow(int index) {
    final pair = _headers[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: pair.keyController,
              decoration: const InputDecoration(hintText: 'Header name'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: pair.valueController,
              decoration: const InputDecoration(hintText: 'Header value'),
            ),
          ),
          IconButton(
            tooltip: 'Remove header',
            onPressed: () => _removeHeader(index),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldRow(int index) {
    final pair = _formFields[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: pair.keyController,
              decoration: const InputDecoration(hintText: 'Key'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: pair.valueController,
              decoration: const InputDecoration(hintText: 'Value'),
            ),
          ),
          IconButton(
            tooltip: 'Remove field',
            onPressed: () => _removeFormField(index),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonNode(dynamic value, {String? label}) {
    if (value is Map<String, dynamic>) {
      final entries = value.entries.toList();
      return ExpansionTile(
        title: Text(
          label != null
              ? '$label (${entries.length})'
              : 'Object (${entries.length})',
          style: const TextStyle(fontFamily: 'Roboto Mono'),
        ),
        children: entries
            .map((entry) => _buildJsonNode(entry.value, label: entry.key))
            .toList(),
      );
    }
    if (value is List) {
      return ExpansionTile(
        title: Text(
          label != null
              ? '$label [${value.length}]'
              : 'Array [${value.length}]',
          style: const TextStyle(fontFamily: 'Roboto Mono'),
        ),
        children: [
          for (int i = 0; i < value.length; i++)
            _buildJsonNode(value[i], label: '[$i]'),
        ],
      );
    }
    final display = value == null ? 'null' : value.toString();
    return ListTile(
      dense: true,
      title: Text(
        label ?? 'value',
        style: const TextStyle(fontFamily: 'Roboto Mono'),
      ),
      subtitle: Text(
        display,
        style: const TextStyle(fontFamily: 'Roboto Mono'),
      ),
    );
  }

  Widget _buildResponseSection(ThemeData theme) {
    final response = _response;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Response', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          )
        else if (response != null) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Chip(
                label: Text(
                  'Status ${response.statusCode}${response.reasonPhrase != null ? ' (${response.reasonPhrase})' : ''}',
                ),
                avatar: const Icon(Icons.http, size: 16),
              ),
              Chip(
                label: Text('Time ${response.elapsedMs} ms'),
                avatar: const Icon(Icons.timer_outlined, size: 16),
              ),
              Chip(
                label: Text('Size ${response.sizeBytes} B'),
                avatar: const Icon(Icons.straighten, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: response.isJson
                    ? () => _copyToClipboard(
                        const JsonEncoder.withIndent(
                          '  ',
                        ).convert(response.parsedJson),
                        'Response JSON copied',
                      )
                    : null,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy JSON'),
              ),
              TextButton.icon(
                onPressed: _curlCommand == null
                    ? null
                    : () => _copyToClipboard(
                        _curlCommand!,
                        'Copied cURL command',
                      ),
                icon: const Icon(Icons.terminal_outlined),
                label: const Text('Copy as cURL'),
              ),
              TextButton.icon(
                onPressed: _latestSnapshot == null ? null : _saveToHistory,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save to history'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            initiallyExpanded: response.isJson,
            title: const Text('Body'),
            children: [
              if (response.isJson)
                _buildJsonNode(response.parsedJson)
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    response.body.isEmpty ? '—' : response.body,
                    style: const TextStyle(fontFamily: 'Roboto Mono'),
                  ),
                ),
            ],
          ),
          ExpansionTile(
            title: const Text('Headers'),
            children: [
              if (response.headers.isEmpty)
                const ListTile(title: Text('No headers in response.'))
              else
                ...response.headers.entries.map(
                  (entry) => ListTile(
                    dense: true,
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontFamily: 'Roboto Mono'),
                    ),
                    subtitle: Text(
                      entry.value,
                      style: const TextStyle(fontFamily: 'Roboto Mono'),
                    ),
                  ),
                ),
            ],
          ),
        ] else
          Text(
            'Send a request to inspect the response here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildHistorySection(ThemeData theme) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._history.map((entry) {
          final snapshot = entry.snapshot;
          final subtitle = '${snapshot.method} • ${snapshot.url}';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Saved ${_formatTimestamp(entry.savedAt)}'),
              trailing: IconButton(
                tooltip: 'Load request',
                icon: const Icon(Icons.north_west_outlined),
                onPressed: () => _applySnapshot(snapshot),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatTimestamp(DateTime value) {
    final now = DateTime.now();
    if (now.difference(value).inMinutes < 1) {
      return 'just now';
    }
    if (now.difference(value).inHours < 1) {
      final mins = now.difference(value).inMinutes;
      return '$mins minute${mins == 1 ? '' : 's'} ago';
    }
    if (now.difference(value).inDays < 1) {
      final hours = now.difference(value).inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = now.difference(value).inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: DropdownMenu<String>(
                        initialSelection: _method,
                        label: const Text('Method'),
                        dropdownMenuEntries: [
                          for (final method in _methods)
                            DropdownMenuEntry(value: method, label: method),
                        ],
                        onSelected: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _method = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _urlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Request URL',
                          hintText: 'https://api.example.com/resource',
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isSending ? null : _send,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: const Text('Send'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SegmentedButton<_RequestBodyMode>(
                      segments: const [
                        ButtonSegment(
                          value: _RequestBodyMode.raw,
                          label: Text('Raw JSON'),
                          icon: Icon(Icons.code),
                        ),
                        ButtonSegment(
                          value: _RequestBodyMode.formData,
                          label: Text('Form-data'),
                          icon: Icon(Icons.table_rows_outlined),
                        ),
                      ],
                      selected: {_bodyMode},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _bodyMode = selection.first;
                          _syncSuggestedContentType(_bodyMode);
                        });
                      },
                    ),
                    TextButton.icon(
                      onPressed: _addHeader,
                      icon: const Icon(Icons.add),
                      label: const Text('Header'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    for (int i = 0; i < _headers.length; i++)
                      _buildHeaderRow(i),
                  ],
                ),
                const Divider(height: 32),
                if (_methodAllowsBody)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _bodyMode == _RequestBodyMode.raw
                        ? TextField(
                            key: const ValueKey('raw'),
                            controller: _rawBodyCtrl,
                            minLines: 8,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Request body',
                              hintText: '{ "key": "value" }',
                            ),
                          )
                        : Column(
                            key: const ValueKey('form'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  for (int i = 0; i < _formFields.length; i++)
                                    _buildFormFieldRow(i),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _addFormField,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Add field'),
                                ),
                              ),
                            ],
                          ),
                  )
                else
                  Text(
                    'Body not sent with $_method requests.',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildResponseSection(theme),
          ),
        ),
        const SizedBox(height: 16),
        _buildHistorySection(theme),
      ],
    );
  }
}

class _QrScannerPanel extends StatefulWidget {
  const _QrScannerPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_QrScannerPanel> createState() => _QrScannerPanelState();
}

class _QrScannerPanelState extends State<_QrScannerPanel> {
  late final MobileScannerController _controller;
  bool _hasCaptured = false;
  String? _lastValue;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    _hasCaptured = widget.session.output.isNotEmpty;
    _lastValue = widget.session.output.isEmpty ? null : widget.session.output;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasCaptured) {
        return;
      }
      _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) {
        continue;
      }
      if (_hasCaptured && value == _lastValue) {
        return;
      }
      _lastValue = value;
      setState(() => _hasCaptured = true);
      widget.viewModel.setSessionState(
        widget.toolId,
        output: value,
        clearError: true,
      );
      _controller.stop();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('QR code detected')));
      }
      break;
    }
  }

  void _restartScanning() {
    setState(() => _hasCaptured = false);
    widget.viewModel.setSessionState(widget.toolId, clearError: true);
    _controller.start();
  }

  Future<void> _toggleTorch(TorchState state) async {
    if (state == TorchState.unavailable) {
      return;
    }
    try {
      await _controller.toggleTorch();
    } on MobileScannerException catch (error) {
      final message =
          error.errorDetails?.message ??
          'Unable to toggle torch (${error.errorCode.name})';
      widget.viewModel.setSessionState(widget.toolId, error: message);
    } catch (error) {
      widget.viewModel.setSessionState(widget.toolId, error: error.toString());
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } on MobileScannerException catch (error) {
      final message =
          error.errorDetails?.message ??
          'Unable to switch camera (${error.errorCode.name})';
      widget.viewModel.setSessionState(widget.toolId, error: message);
    } catch (error) {
      widget.viewModel.setSessionState(widget.toolId, error: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: _handleDetection,
                  errorBuilder: (context, error) {
                    final message =
                        error.errorDetails?.message ??
                        'Camera unavailable (${error.errorCode.name})';
                    widget.viewModel.setSessionState(
                      widget.toolId,
                      error: message,
                    );
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    _hasCaptured
                        ? 'Scan stored. Use "Scan again" to capture another code.'
                        : 'Align the QR code inside the frame to capture it instantly.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_hasCaptured)
                  Container(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text('QR captured', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final torchState = state.torchState;
                final isOn = torchState == TorchState.on;
                final unavailable = torchState == TorchState.unavailable;
                return IconButton.filledTonal(
                  tooltip: unavailable
                      ? 'Torch unavailable on this device'
                      : isOn
                      ? 'Turn torch off'
                      : 'Turn torch on',
                  onPressed: unavailable
                      ? null
                      : () => _toggleTorch(torchState),
                  icon: Icon(
                    isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  ),
                );
              },
            ),
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final facing = state.cameraDirection;
                final cameraCount = state.availableCameras;
                final canSwitch = cameraCount == null || cameraCount > 1;
                return IconButton.filledTonal(
                  tooltip: canSwitch ? 'Switch camera' : 'Single-camera device',
                  onPressed: canSwitch ? _switchCamera : null,
                  icon: Icon(
                    facing == CameraFacing.back
                        ? Icons.camera_front_outlined
                        : Icons.camera_rear_outlined,
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              onPressed: _hasCaptured ? _restartScanning : null,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Scan again'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _hasCaptured
              ? 'Copy the decoded value from the output below or start a new scan.'
              : 'The scanner pauses automatically once a code is detected.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
