import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageService {
  Future<File?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<File?> compressImage(File image) async {
    final targetPath = image.path.replaceAll('.', '_compressed.');
    final result = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      targetPath,
      quality: 88,
    );
    return result != null ? File(result.path) : null;
  }
}
