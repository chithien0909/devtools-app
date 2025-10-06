import 'dart:typed_data';

import 'package:devtools_plus/services/image_format_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImageFormatScreen extends StatefulWidget {
  const ImageFormatScreen({super.key});

  @override
  State<ImageFormatScreen> createState() => _ImageFormatScreenState();
}

class _ImageFormatScreenState extends State<ImageFormatScreen> {
  final ImageFormatService _service = const ImageFormatService();
  ImageTargetFormat _target = ImageTargetFormat.png;
  int _quality = 90;
  String _status = '';

  Future<void> _pickAndConvert() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false);
    if (res == null) return;
    final Uint8List? bytes = res.files.single.bytes;
    if (bytes == null) return;
    try {
      final out = await _service.convert(bytes, _target, quality: _quality);
      setState(() => _status = 'Converted (size: ' + out.lengthInBytes.toString() + ' bytes)');
      await FilePicker.platform.saveFile(fileName: _fileNameForTarget(res.files.single.name), bytes: out);
    } catch (e) {
      _show(e.toString());
    }
  }

  String _fileNameForTarget(String name) {
    final base = name.contains('.') ? name.substring(0, name.lastIndexOf('.')) : name;
    final ext = switch (_target) {
      ImageTargetFormat.png => '.png',
      ImageTargetFormat.jpg => '.jpg',
      ImageTargetFormat.webp => '.webp',
    };
    return base + ext;
  }

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Format Converter'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<ImageTargetFormat>(
              value: _target,
              items: const [
                DropdownMenuItem(value: ImageTargetFormat.png, child: Text('PNG')),
                DropdownMenuItem(value: ImageTargetFormat.jpg, child: Text('JPG')),
                DropdownMenuItem(value: ImageTargetFormat.webp, child: Text('WebP')),
              ],
              onChanged: (v) => setState(() => _target = v ?? ImageTargetFormat.png),
            ),
          ),
          if (_target != ImageTargetFormat.png)
            Row(children: [
              const Text('Quality'),
              Slider(value: _quality.toDouble(), min: 1, max: 100, divisions: 99, label: _quality.toString(), onChanged: (v) => setState(() => _quality = v.round())),
            ]),
          IconButton(onPressed: _pickAndConvert, icon: const Icon(Icons.file_open)),
        ],
      ),
      body: Center(child: Text(_status)),
    );
  }
}
