import 'dart:io';

import 'package:devtools_plus/services/image_service.dart';
import 'package:flutter/material.dart';

class ImageCompressorScreen extends StatefulWidget {
  const ImageCompressorScreen({super.key});

  @override
  State<ImageCompressorScreen> createState() => _ImageCompressorScreenState();
}

class _ImageCompressorScreenState extends State<ImageCompressorScreen> {
  final _imageService = ImageService();
  File? _originalImage;
  File? _compressedImage;

  Future<void> _pickImage() async {
    final image = await _imageService.pickImage();
    setState(() {
      _originalImage = image;
      _compressedImage = null;
    });
  }

  Future<void> _compressImage() async {
    if (_originalImage != null) {
      final compressed = await _imageService.compressImage(_originalImage!);
      setState(() {
        _compressedImage = compressed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Compressor')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 16),
            if (_originalImage != null)
              Column(
                children: [
                  Image.file(_originalImage!, height: 200),
                  const SizedBox(height: 8),
                  Text('Original size: ${_originalImage!.lengthSync()} bytes'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _compressImage,
                    child: const Text('Compress Image'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (_compressedImage != null)
              Column(
                children: [
                  Image.file(_compressedImage!, height: 200),
                  const SizedBox(height: 8),
                  Text(
                    'Compressed size: ${_compressedImage!.lengthSync()} bytes',
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
