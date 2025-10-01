import 'dart:io';

import 'package:devtools_plus/services/pdf_service.dart';
import 'package:flutter/material.dart';

class PdfGeneratorScreen extends StatefulWidget {
  const PdfGeneratorScreen({super.key});

  @override
  State<PdfGeneratorScreen> createState() => _PdfGeneratorScreenState();
}

class _PdfGeneratorScreenState extends State<PdfGeneratorScreen> {
  final _pdfService = PdfService();
  List<File> _images = [];

  Future<void> _pickImages() async {
    final images = await _pdfService.pickImages();
    setState(() {
      _images = images;
    });
  }

  Future<void> _generatePdf() async {
    if (_images.isNotEmpty) {
      await _pdfService.generatePdf(_images);
    } else {
      // Show a snackbar or some other feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick some images first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteW = constraints.hasBoundedWidth;
        final hasFiniteH = constraints.hasBoundedHeight;
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            width: hasFiniteW ? constraints.maxWidth : null,
            height: hasFiniteH ? constraints.maxHeight : null,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: hasFiniteH
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'PDF Generator',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImages,
                      child: const Text('Pick Images'),
                    ),
                    const SizedBox(height: 16),
                    if (hasFiniteH)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Image.file(
                                _images[index],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                _images[index].path.split('\\\\').last,
                              ),
                            );
                          },
                        ),
                      )
                    else
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _images.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Image.file(
                                _images[index],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                _images[index].path.split('\\\\').last,
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generatePdf,
                      child: const Text('Generate PDF'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
