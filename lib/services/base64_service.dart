import 'dart:convert';

class Base64Service {
  const Base64Service();

  Future<String> encode(String input) async {
    if (input.isEmpty) {
      return '';
    }
    final bytes = utf8.encode(input);
    return base64.encode(bytes);
  }

  Future<String> decode(String input) async {
    if (input.isEmpty) {
      return '';
    }
    try {
      final bytes = base64.decode(input);
      return utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('Input is not valid Base64.');
    }
  }
}
