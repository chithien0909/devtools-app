import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:devtools_plus/services/pdf_split_merge_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class PdfSplitMergeScreen extends StatefulWidget {
  const PdfSplitMergeScreen({super.key});

  @override
  State<PdfSplitMergeScreen> createState() => _PdfSplitMergeScreenState();
}

class _PdfSplitMergeScreenState extends State<PdfSplitMergeScreen> {
  final PdfSplitMergeService _service = const PdfSplitMergeService();
  final List<_RangeField> _ranges = [
    const PdfPageRange(start: 1, end: 1),
  ].map(_RangeField.fromRange).toList();
  final List<_MergeEntry> _mergeEntries = [];

  Uint8List? _primaryBytes;
  String? _primaryPath;
  PdfDocumentSummary? _summary;
  List<Uint8List> _previewImages = const [];
  bool _loading = false;

  @override
  void dispose() {
    for (final range in _ranges) {
      range.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPrimaryPdf() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final file = result?.files.single;
    if (file == null) return;

    final bytes = await _loadBytes(file);
    setState(() {
      _primaryBytes = bytes;
      _primaryPath = file.path ?? file.name;
      _summary = null;
      _previewImages = const [];
    });

    await _loadSummaryAndPreview();
  }

  Future<void> _loadSummaryAndPreview() async {
    if (_primaryBytes == null) return;
    setState(() => _loading = true);
    try {
      final summary = await _service.inspect(_primaryBytes!);
      final previewCount = min(4, summary.pageCount);
      final previews = <Uint8List>[];
      for (var i = 0; i < previewCount; i++) {
        previews.add(
          await _service.renderPagePreview(_primaryBytes!, i, targetWidth: 400),
        );
      }
      setState(() {
        _summary = summary;
        _previewImages = previews;
        if (_ranges.isEmpty) {
          _ranges.add(_RangeField.fromRange(PdfPageRange.single(1)));
        }
      });
    } catch (error) {
      _showMessage('Failed to analyse PDF: $error', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _split() async {
    if (_primaryBytes == null) {
      _showMessage('Select a primary PDF first', error: true);
      return;
    }
    final summary = _summary;
    if (summary == null) {
      _showMessage('Still analysing PDF…', error: true);
      return;
    }

    final ranges = _ranges.map((field) => field.toRange()).toList();
    final outputs = await _service.splitDocument(_primaryBytes!, ranges);
    final outputDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select folder to store split PDFs',
    );
    if (outputDir == null) return;

    for (var i = 0; i < outputs.length; i++) {
      final name =
          '${p.basenameWithoutExtension(_primaryPath ?? 'document')}_part${i + 1}.pdf';
      final target = File(p.join(outputDir, name));
      await target.writeAsBytes(outputs[i], flush: true);
    }
    _showMessage('Saved ${outputs.length} split document(s) to $outputDir');
  }

  Future<void> _addMergeEntries() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null) return;
    final additions = <_MergeEntry>[];
    for (final file in result.files) {
      final bytes = await _loadBytes(file);
      additions.add(_MergeEntry(name: file.path ?? file.name, bytes: bytes));
    }
    setState(() => _mergeEntries.addAll(additions));
  }

  Future<void> _merge() async {
    if (_mergeEntries.isEmpty) {
      _showMessage('Add PDFs to merge first', error: true);
      return;
    }
    final merged = await _service.mergeDocuments(
      _mergeEntries.map((entry) => entry.bytes).toList(),
    );
    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Save merged PDF',
      fileName: 'merged.pdf',
      bytes: merged,
    );
    if (path == null) return;
    _showMessage('Merged PDF saved to $path');
  }

  Future<Uint8List> _loadBytes(PlatformFile file) async {
    if (file.bytes != null) {
      return file.bytes!;
    }
    if (file.path != null) {
      return await File(file.path!).readAsBytes();
    }
    throw ArgumentError('Unable to load PDF bytes for ${file.name}');
  }

  void _addRange() {
    setState(
      () => _ranges.add(
        _RangeField.fromRange(PdfPageRange.single(_ranges.length + 1)),
      ),
    );
  }

  void _removeRange(int index) {
    if (_ranges.length == 1) return;
    final removed = _ranges.removeAt(index);
    removed.dispose();
    setState(() {});
  }

  void _clearMergeEntries() {
    setState(() => _mergeEntries.clear());
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Split & Merge')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: _loading ? null : _pickPrimaryPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: Text(
                _primaryPath == null
                    ? 'Select source PDF'
                    : 'Source: ${p.basename(_primaryPath!)}',
              ),
            ),
            if (_loading) const LinearProgressIndicator(),
            if (summary != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    Chip(label: Text('Pages: ${summary.pageCount}')),
                    if (summary.title != null && summary.title!.isNotEmpty)
                      Chip(label: Text('Title: ${summary.title}')),
                  ],
                ),
              ),
            if (_previewImages.isNotEmpty)
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) =>
                      Image.memory(_previewImages[index]),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _previewImages.length,
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Split ranges',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                for (var i = 0; i < _ranges.length; i++)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ranges[i].startController,
                              decoration: const InputDecoration(
                                labelText: 'Start page',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _ranges[i].endController,
                              decoration: const InputDecoration(
                                labelText: 'End page',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Remove range',
                            onPressed: () => _removeRange(i),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addRange,
                    icon: const Icon(Icons.add),
                    label: const Text('Add range'),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _split,
                  icon: const Icon(Icons.call_split),
                  label: const Text('Split PDF'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Merge queue', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_mergeEntries.isEmpty)
              const Text(
                'No PDFs queued. Use "Add PDFs" to select multiple files.',
              )
            else
              Column(
                children: _mergeEntries
                    .asMap()
                    .entries
                    .map(
                      (entry) => ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: Text(p.basename(entry.value.name)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _mergeEntries.removeAt(entry.key)),
                        ),
                      ),
                    )
                    .toList(),
              ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: _addMergeEntries,
                  icon: const Icon(Icons.add),
                  label: const Text('Add PDFs'),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _mergeEntries.isEmpty ? null : _clearMergeEntries,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _mergeEntries.isEmpty ? null : _merge,
                  icon: const Icon(Icons.merge_type),
                  label: const Text('Merge PDFs'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeField {
  _RangeField(this.startController, this.endController);

  factory _RangeField.fromRange(PdfPageRange range) => _RangeField(
    TextEditingController(text: '${range.start}'),
    TextEditingController(text: '${range.end}'),
  );

  final TextEditingController startController;
  final TextEditingController endController;

  PdfPageRange toRange() {
    final start = int.tryParse(startController.text.trim()) ?? 1;
    final end = int.tryParse(endController.text.trim()) ?? start;
    return PdfPageRange(start: start, end: end);
  }

  void dispose() {
    startController.dispose();
    endController.dispose();
  }
}

class _MergeEntry {
  _MergeEntry({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}
