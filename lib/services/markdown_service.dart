import 'dart:typed_data';

import 'package:flutter_markdown/flutter_markdown.dart' show MarkdownStyleSheet;
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MarkdownService {
  const MarkdownService();

  String renderHtml(String markdownSource) {
    if (markdownSource.trim().isEmpty) return '';
    return md.markdownToHtml(markdownSource);
  }

  Future<Uint8List> renderPdfBytes(
    String markdownSource, {
    PdfPageFormat pageFormat = PdfPageFormat.a4,
    MarkdownStyleSheet? style,
  }) async {
    final doc = pw.Document();
    final lines = markdownSource.split('\n');

    final textStyle = pw.TextStyle(fontSize: 12);
    final h1 = pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold);
    final h2 = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    final h3 = pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold);
    final mono = pw.TextStyle(font: pw.Font.courier(), fontSize: 10);

    doc.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        build: (ctx) {
          final widgets = <pw.Widget>[];
          final buffer = StringBuffer();
          bool inCode = false;
          for (final line in lines) {
            if (line.startsWith('```')) {
              if (!inCode) {
                inCode = true;
                buffer.clear();
              } else {
                inCode = false;
                widgets.add(pw.Container(
                  width: double.infinity,
                  color: const PdfColor.fromInt(0xFFEEEEEE),
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(buffer.toString(), style: mono),
                ));
                buffer.clear();
              }
              continue;
            }

            if (inCode) {
              buffer.writeln(line);
              continue;
            }

            if (line.startsWith('# ')) {
              widgets.add(pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
                child: pw.Text(line.substring(2), style: h1),
              ));
            } else if (line.startsWith('## ')) {
              widgets.add(pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
                child: pw.Text(line.substring(3), style: h2),
              ));
            } else if (line.startsWith('### ')) {
              widgets.add(pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
                child: pw.Text(line.substring(4), style: h3),
              ));
            } else if (line.trim().isEmpty) {
              widgets.add(pw.SizedBox(height: 8));
            } else if (line.startsWith('- ')) {
              widgets.add(pw.Bullet(text: line.substring(2), style: textStyle));
            } else {
              widgets.add(pw.Text(line, style: textStyle));
            }
          }
          return widgets;
        },
      ),
    );

    return doc.save();
  }
}
