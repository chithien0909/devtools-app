import 'dart:typed_data';

import 'package:exif/exif.dart' as exif;
import 'package:image/image.dart' as img;

class ExifService {
  const ExifService();

  Future<Map<String, String>> readTags(Uint8List bytes) async {
    final data = await exif.readExifFromBytes(bytes);
    return data.map((key, value) => MapEntry(key, value.toString()));
  }

  Future<Uint8List> stripTags(Uint8List bytes) async {
    final decoder = img.findDecoderForData(bytes);
    if (decoder == null) {
      throw const FormatException('Unsupported image format');
    }
    final decoded = decoder.decode(bytes);
    if (decoded == null) {
      throw const FormatException('Unable to decode image');
    }
    decoded.exif.clear();

    if (decoder is img.JpegDecoder) {
      return Uint8List.fromList(img.encodeJpg(decoded, quality: 95));
    }
    if (decoder is img.PngDecoder) {
      return Uint8List.fromList(img.encodePng(decoded));
    }
    // WebP re-encode not supported by current image API; fallback to PNG
    if (decoder is img.WebPDecoder) {
      return Uint8List.fromList(img.encodePng(decoded));
    }
    if (decoder is img.TiffDecoder) {
      return Uint8List.fromList(img.encodeTiff(decoded));
    }
    throw const FormatException('Unsupported image format for stripping EXIF');
  }
}
