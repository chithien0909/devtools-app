import 'dart:typed_data';

import 'package:devtools_plus/services/markdown_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:printing/printing.dart';

class MarkdownScreen extends StatefulWidget {
  const MarkdownScreen({super.key});

  @override
  State<MarkdownScreen> createState() => _MarkdownScreenState();
}

class _MarkdownScreenState extends State<MarkdownScreen> {
  final MarkdownService _service = const MarkdownService();
  final TextEditingController _controller = TextEditingController(
    text: '# Markdown Title\n\nType here...',
  );

  bool _showPreview = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _exportPdf() async {
    try {
      final Uint8List bytes = await _service.renderPdfBytes(_controller.text);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markdown Previewer & Export'),
        actions: [
          IconButton(
            tooltip: 'Toggle preview',
            onPressed: () => setState(() => _showPreview = !_showPreview),
            icon: const Icon(Icons.preview),
          ),
          IconButton(
            tooltip: 'Export to PDF',
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '# Hello world',
                ),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          if (_showPreview) ...[
            const VerticalDivider(width: 1),
            Expanded(child: Markdown(data: _controller.text)),
          ],
        ],
      ),
    );
  }
}
