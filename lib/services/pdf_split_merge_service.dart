import 'dart:typed_data';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';

class PdfPageRange {
  const PdfPageRange({required this.start, required this.end})
    : assert(start > 0),
      assert(end > 0),
      assert(start <= end);

  final int start;
  final int end;

  PdfPageRange clamp(int maxPage) {
    final clampedStart = start.clamp(1, maxPage);
    final clampedEnd = end.clamp(1, maxPage);
    if (clampedStart > clampedEnd) {
      return PdfPageRange(start: clampedStart, end: clampedStart);
    }
    return PdfPageRange(start: clampedStart, end: clampedEnd);
  }

  static PdfPageRange single(int page) => PdfPageRange(start: page, end: page);
}

class PdfPageDimension {
  const PdfPageDimension(this.width, this.height);

  final double width;
  final double height;
}

class PdfDocumentSummary {
  const PdfDocumentSummary({
    required this.pageCount,
    required this.title,
    required this.pageDimensions,
  });

  final int pageCount;
  final String? title;
  final List<PdfPageDimension> pageDimensions;
}

class PdfSplitMergeService {
  const PdfSplitMergeService();

  Future<PdfDocumentSummary> inspect(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final pageDimensions = List.generate(document.pages.count, (index) {
        final size = document.pages[index].size;
        return PdfPageDimension(size.width, size.height);
      });
      return PdfDocumentSummary(
        pageCount: document.pages.count,
        title: document.documentInformation.title,
        pageDimensions: pageDimensions,
      );
    } finally {
      document.dispose();
    }
  }

  Future<List<Uint8List>> splitDocument(
    Uint8List bytes,
    List<PdfPageRange> ranges,
  ) async {
    final source = PdfDocument(inputBytes: bytes);
    try {
      final maxPage = source.pages.count;
      final results = <Uint8List>[];
      for (final range in ranges) {
        final safeRange = range.clamp(maxPage);
        final output = PdfDocument();
        for (var i = safeRange.start - 1; i <= safeRange.end - 1; i++) {
          final srcPage = source.pages[i];
          output.pageSettings.size = srcPage.size;
          final newPage = output.pages.add();
          final template = srcPage.createTemplate();
          newPage.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            Size(srcPage.size.width, srcPage.size.height),
          );
        }
        results.add(Uint8List.fromList(await output.save()));
        output.dispose();
      }
      return results;
    } finally {
      source.dispose();
    }
  }

  Future<Uint8List> mergeDocuments(List<Uint8List> documents) async {
    if (documents.isEmpty) {
      throw ArgumentError('At least one document is required to merge.');
    }
    final output = PdfDocument();
    try {
      for (final docBytes in documents) {
        final document = PdfDocument(inputBytes: docBytes);
        for (var i = 0; i < document.pages.count; i++) {
          final srcPage = document.pages[i];
          output.pageSettings.size = srcPage.size;
          final newPage = output.pages.add();
          final template = srcPage.createTemplate();
          newPage.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            Size(srcPage.size.width, srcPage.size.height),
          );
        }
        document.dispose();
      }
      return Uint8List.fromList(await output.save());
    } finally {
      output.dispose();
    }
  }

  Future<Uint8List> renderPagePreview(
    Uint8List bytes,
    int pageIndex, {
    int targetWidth = 1024,
  }) async {
    final doc = PdfDocument(inputBytes: bytes);
    try {
      if (pageIndex < 0 || pageIndex >= doc.pages.count) {
        throw RangeError.index(pageIndex, doc.pages, 'pageIndex');
      }
      final pageSize = doc.pages[pageIndex].size;
      final dpi = (targetWidth / pageSize.width) * 72.0;
      final stream = Printing.raster(bytes, pages: [pageIndex + 1], dpi: dpi);
      final first = await stream.first;
      final png = await first.toPng();
      return png;
    } finally {
      doc.dispose();
    }
  }
}
