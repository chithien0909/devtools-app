import 'dart:typed_data';

class ExifService {
  const ExifService();

  Future<Map<String, String>> readTags(Uint8List bytes) async {
    return {};
  }

  Future<Uint8List> stripTags(Uint8List bytes) async {
    return bytes;
  }
}
