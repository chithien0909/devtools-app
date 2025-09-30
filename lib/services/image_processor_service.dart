import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum ImageOutputFormat { png, jpeg, webp, pdf }

enum ResizeMode { none, percentage, custom }

class ImageProcessingInput {
  ImageProcessingInput({required this.bytes, required this.originalName});

  final Uint8List bytes;
  final String originalName;
}

class ImageProcessingOptions {
  ImageProcessingOptions({
    required this.outputFormat,
    required this.resizeMode,
    this.quality = 80,
    this.resizePercentage = 100,
    this.targetWidth,
    this.targetHeight,
    this.maintainAspectRatio = true,
    this.keepMetadata = true,
    this.pdfPageFormat = PdfPageFormat.a4,
  });

  final ImageOutputFormat outputFormat;
  final ResizeMode resizeMode;
  final int quality;
  final double resizePercentage;
  final int? targetWidth;
  final int? targetHeight;
  final bool maintainAspectRatio;
  final bool keepMetadata;
  final PdfPageFormat pdfPageFormat;
}

class ProcessedImageFile {
  ProcessedImageFile({
    required this.fileName,
    required this.bytes,
    required this.width,
    required this.height,
    required this.mimeType,
  });

  final String fileName;
  final Uint8List bytes;
  final int width;
  final int height;
  final String mimeType;
}

class ProcessedPdfFile {
  ProcessedPdfFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;
}

class ImageBatchResult {
  ImageBatchResult({required this.files, this.pdfFile, this.archiveBytes});

  final List<ProcessedImageFile> files;
  final ProcessedPdfFile? pdfFile;
  final Uint8List? archiveBytes;
}

class ImageProcessorService {
  const ImageProcessorService();

  Future<ImageBatchResult> process(
    List<ImageProcessingInput> inputs,
    ImageProcessingOptions options,
  ) async {
    if (inputs.isEmpty) {
      throw const ImageProcessingException('Select at least one image to begin.');
    }

    final outputFiles = <ProcessedImageFile>[];
    final pdfImages = <img.Image>[];

    for (final input in inputs) {
      final decoded = _decodeImage(input.bytes);
      if (decoded == null) {
        continue;
      }

      final resized = _resizeImage(decoded, options);
      if (options.outputFormat == ImageOutputFormat.pdf) {
        pdfImages.add(resized);
      } else {
        final processed = await _encodeImage(
          resized,
          input.originalName,
          options,
        );
        outputFiles.add(processed);
      }
    }

    if (options.outputFormat == ImageOutputFormat.pdf) {
      if (pdfImages.isEmpty) {
        throw const ImageProcessingException('None of the selected files could be converted to PDF.');
      }
      final pdfBytes = await _buildPdf(pdfImages, options);
      final pdfFile = ProcessedPdfFile(
        fileName: 'compressed_images.pdf',
        bytes: pdfBytes,
      );
      final archive = Uint8List.fromList(
        ZipEncoder().encode(
          Archive()..addFile(ArchiveFile(pdfFile.fileName, pdfFile.bytes.length, pdfFile.bytes)),
        )!,
      );
      return ImageBatchResult(files: const [], pdfFile: pdfFile, archiveBytes: archive);
    }

    if (outputFiles.isEmpty) {
      throw const ImageProcessingException('No images could be processed with the chosen settings.');
    }

    final archive = _buildArchive(outputFiles);
    return ImageBatchResult(files: outputFiles, archiveBytes: archive);
  }

  img.Image? _decodeImage(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      return decoded;
    } catch (_) {
      return null;
    }
  }

  img.Image _resizeImage(img.Image source, ImageProcessingOptions options) {
    if (options.resizeMode == ResizeMode.none) {
      return source;
    }

    int targetWidth = source.width;
    int targetHeight = source.height;

    if (options.resizeMode == ResizeMode.percentage) {
      final factor = options.resizePercentage.clamp(1, 400) / 100.0;
      targetWidth = (source.width * factor).round().clamp(1, 10000);
      targetHeight = (source.height * factor).round().clamp(1, 10000);
    } else {
      final width = options.targetWidth ?? source.width;
      final height = options.targetHeight ?? source.height;
      if (options.maintainAspectRatio) {
        final ratio = source.width / source.height;
        if (width == 0 || height == 0) {
          if (width == 0) {
            targetHeight = height;
            targetWidth = (height * ratio).round();
          } else {
            targetWidth = width;
            targetHeight = (width / ratio).round();
          }
        } else {
          final widthBased = width / source.width;
          final heightBased = height / source.height;
          final factor = widthBased < heightBased ? widthBased : heightBased;
          targetWidth = (source.width * factor).round();
          targetHeight = (source.height * factor).round();
        }
      } else {
        targetWidth = width;
        targetHeight = height;
      }
      targetWidth = targetWidth.clamp(1, 10000);
      targetHeight = targetHeight.clamp(1, 10000);
    }

    if (targetWidth == source.width && targetHeight == source.height) {
      return source;
    }

    return img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      maintainAspect: false,
      interpolation: img.Interpolation.cubic,
    );
  }

  Future<ProcessedImageFile> _encodeImage(
    img.Image image,
    String originalName,
    ImageProcessingOptions options,
  ) async {
    final baseName = _buildBaseName(originalName);
    final keepMeta = options.keepMetadata;
    final quality = options.quality.clamp(0, 100);

    switch (options.outputFormat) {
      case ImageOutputFormat.png:
        final compressionLevel = ((100 - quality) / 11).round().clamp(0, 9);
        final working = image.clone();
        if (!keepMeta) {
          working.exif = img.ExifData();
        }
        final bytes = Uint8List.fromList(
          img.encodePng(
            working,
            level: compressionLevel,
            filter: img.PngFilter.paeth,
          ),
        );
        return ProcessedImageFile(
          fileName: '$baseName.png',
          bytes: bytes,
          width: image.width,
          height: image.height,
          mimeType: 'image/png',
        );
      case ImageOutputFormat.jpeg:
        final working = image.clone();
        if (!keepMeta) {
          working.exif = img.ExifData();
        }
        final bytes = Uint8List.fromList(
          img.encodeJpg(
            working,
            quality: quality,
          ),
        );
        return ProcessedImageFile(
          fileName: '$baseName.jpg',
          bytes: bytes,
          width: image.width,
          height: image.height,
          mimeType: 'image/jpeg',
        );
      case ImageOutputFormat.webp:
        final working = image.clone();
        if (!keepMeta) {
          working.exif = img.ExifData();
        }
        final encoded = img.encodeNamedImage('$baseName.webp', working);
        if (encoded == null) {
          throw const ImageProcessingException('WebP encoding is not supported on this platform.');
        }
        final bytes = Uint8List.fromList(encoded);
        return ProcessedImageFile(
          fileName: '$baseName.webp',
          bytes: bytes,
          width: image.width,
          height: image.height,
          mimeType: 'image/webp',
        );
      case ImageOutputFormat.pdf:
        throw StateError('PDF encoding handled separately.');
    }
  }

  Future<Uint8List> _buildPdf(
    List<img.Image> images,
    ImageProcessingOptions options,
  ) async {
    final document = pw.Document();
    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      final memory = pw.MemoryImage(img.encodeJpg(image, quality: 90));
      document.addPage(
        pw.Page(
          pageFormat: options.pdfPageFormat,
          build: (context) => pw.Center(child: pw.Image(memory, fit: pw.BoxFit.contain)),
        ),
      );
    }
    return Uint8List.fromList(await document.save());
  }

  Uint8List? _buildArchive(List<ProcessedImageFile> files) {
    if (files.length <= 1) {
      return null;
    }
    final archive = Archive();
    for (final file in files) {
      archive.addFile(ArchiveFile(file.fileName, file.bytes.length, file.bytes));
    }
    final encoder = ZipEncoder();
    final data = encoder.encode(archive);
    return data == null ? null : Uint8List.fromList(data);
  }

  String _buildBaseName(String original) {
    final sanitized = original.split('.').first;
    return sanitized.isEmpty ? 'image' : sanitized;
  }
}

class ImageProcessingException implements Exception {
  const ImageProcessingException(this.message);

  final String message;

  @override
  String toString() => 'ImageProcessingException: $message';
}
