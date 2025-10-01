import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<List<File>> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      return result.paths.map((path) => File(path!)).toList();
    } else {
      return [];
    }
  }

  Future<void> generatePdf(List<File> images) async {
    final pdf = pw.Document();

    for (final image in images) {
      final imageProvider = pw.MemoryImage(image.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(imageProvider));
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
