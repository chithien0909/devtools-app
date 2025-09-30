import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum PdfLayoutMode { vertical, horizontalGrid }

enum PdfScalingMode { fitToPage, originalSize, stretch }

class PdfImageAsset {
  PdfImageAsset({
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

class PdfGenerationResult {
  PdfGenerationResult({required this.bytes, required this.filePath});

  final Uint8List bytes;
  final String filePath;
}

class PdfService {
  const PdfService();

  Future<PdfGenerationResult> generatePdf({
    required List<PdfImageAsset> images,
    required PdfLayoutMode layout,
    required PdfPageFormat pageFormat,
    PdfScalingMode scaling = PdfScalingMode.fitToPage,
    double margin = 20,
    String? watermark,
    String? headerText,
    String? footerText,
    String fileName = 'output.pdf',
  }) async {
    if (images.isEmpty) {
      throw const PdfException('Provide at least one image to generate a PDF.');
    }

    final document = pw.Document();
    final marginInsets = pw.EdgeInsets.all(margin);

    if (layout == PdfLayoutMode.vertical) {
      document.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: marginInsets,
          header: headerText == null
              ? null
              : (context) => pw.Text(
                  headerText,
                  style: const pw.TextStyle(fontSize: 12),
                ),
          footer: footerText == null
              ? null
              : (context) => pw.Text(
                  footerText,
                  style: const pw.TextStyle(fontSize: 10),
                ),
          build: (context) => images
              .map(
                (image) => _decorateWithWatermark(
                  child: _buildImage(image, scaling),
                  watermark: watermark,
                ),
              )
              .map(
                (widget) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 12),
                  child: widget,
                ),
              )
              .toList(),
        ),
      );
    } else {
      document.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: marginInsets,
          header: headerText == null
              ? null
              : (context) => pw.Text(
                  headerText,
                  style: const pw.TextStyle(fontSize: 12),
                ),
          footer: footerText == null
              ? null
              : (context) => pw.Text(
                  footerText,
                  style: const pw.TextStyle(fontSize: 10),
                ),
          build: (context) {
            final widgets = <pw.Widget>[];
            final availableWidth = pageFormat.availableWidth;
            final crossAxisCount = availableWidth > 500 ? 2 : 1;
            final spacing = 12.0;
            final itemWidth =
                (availableWidth - (spacing * (crossAxisCount - 1))) /
                crossAxisCount;

            final rows = <List<pw.Widget>>[];
            for (var i = 0; i < images.length; i += crossAxisCount) {
              final rowChildren = <pw.Widget>[];
              for (
                var j = i;
                j < images.length && j < i + crossAxisCount;
                j++
              ) {
                final image = images[j];
                rowChildren.add(
                  pw.Container(
                    width: itemWidth,
                    padding: pw.EdgeInsets.only(
                      right: (j < i + crossAxisCount - 1) ? spacing : 0,
                      bottom: spacing,
                    ),
                    child: _decorateWithWatermark(
                      child: _buildImage(image, scaling),
                      watermark: watermark,
                    ),
                  ),
                );
              }
              rows.add(rowChildren);
            }

            for (final row in rows) {
              widgets.add(
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: row,
                ),
              );
            }
            return widgets;
          },
        ),
      );
    }

    final bytes = await document.save();
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedName = fileName.trim().isEmpty ? 'output.pdf' : fileName;
    final path = p.join(directory.path, sanitizedName);
    final outputFile = File(path);
    await outputFile.writeAsBytes(bytes, flush: true);

    return PdfGenerationResult(bytes: bytes, filePath: outputFile.path);
  }

  pw.Widget _decorateWithWatermark({
    required pw.Widget child,
    String? watermark,
  }) {
    if (watermark == null || watermark.trim().isEmpty) {
      return child;
    }
    return pw.Stack(
      children: [
        child,
        pw.Positioned.fill(
          child: pw.Center(
            child: pw.Opacity(
              opacity: 0.12,
              child: pw.Transform.rotate(
                angle: -0.3,
                child: pw.Text(
                  watermark,
                  style: pw.TextStyle(
                    fontSize: 48,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildImage(PdfImageAsset image, PdfScalingMode scaling) {
    final memoryImage = pw.MemoryImage(image.bytes);

    switch (scaling) {
      case PdfScalingMode.fitToPage:
        return pw.AspectRatio(
          aspectRatio: image.width / image.height,
          child: pw.FittedBox(
            fit: pw.BoxFit.contain,
            child: pw.Image(memoryImage),
          ),
        );
      case PdfScalingMode.originalSize:
        return pw.Align(
          alignment: pw.Alignment.topCenter,
          child: pw.Image(memoryImage),
        );
      case PdfScalingMode.stretch:
        return pw.SizedBox.expand(
          child: pw.Image(memoryImage, fit: pw.BoxFit.fill),
        );
    }
  }
}

class PdfException implements Exception {
  const PdfException(this.message);

  final String message;

  @override
  String toString() => 'PdfException: $message';
}
