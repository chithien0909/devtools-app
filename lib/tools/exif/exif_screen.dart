import 'dart:typed_data';

import 'package:devtools_plus/services/exif_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExifScreen extends StatefulWidget {
  const ExifScreen({super.key});

  @override
  State<ExifScreen> createState() => _ExifScreenState();
}

class _ExifScreenState extends State<ExifScreen> {
  final ExifService _service = const ExifService();
  Map<String, String> _tags = const {};
  String _status = '';

  Future<void> _pickAndRead() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (res == null) return;
    final Uint8List? bytes = res.files.single.bytes;
    if (bytes == null) return;
    try {
      final tags = await _service.readTags(bytes);
      setState(() { _tags = tags; _status = 'Tags: ' + tags.length.toString(); });
    } catch (e) {
      _show(e.toString());
    }
  }

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXIF Viewer / Stripper'),
        actions: [IconButton(onPressed: _pickAndRead, icon: const Icon(Icons.file_open))],
      ),
      body: _tags.isEmpty
          ? Center(child: Text(_status.isEmpty ? 'Pick an image to view EXIF' : _status))
          : ListView(
              children: _tags.entries
                  .map((e) => ListTile(
                        dense: true,
                        title: Text(e.key, style: const TextStyle(fontFamily: 'monospace')),
                        subtitle: Text(e.value),
                      ))
                  .toList(),
            ),
    );
  }
}
