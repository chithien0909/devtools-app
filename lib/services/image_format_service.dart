import 'dart:typed_data';

import 'package:image/image.dart' as img;

enum ImageTargetFormat { png, jpg }

class ImageFormatService {
  const ImageFormatService();

  Future<Uint8List> convert(Uint8List bytes, ImageTargetFormat target, {int quality = 90}) async {
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw ArgumentError('Unsupported or corrupt image');
    }
    switch (target) {
      case ImageTargetFormat.png:
        return Uint8List.fromList(img.encodePng(image));
      case ImageTargetFormat.jpg:
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    }
  }
}
