import 'dart:convert';

class JsonFormatterService {
  const JsonFormatterService();

  Future<String> prettify(String input) async {
    if (input.trim().isEmpty) {
      return '';
    }
    try {
      final jsonObject = jsonDecode(input);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(jsonObject);
    } on FormatException {
      throw const FormatException('Input is not valid JSON.');
    }
  }

  Future<String> minify(String input) async {
    if (input.trim().isEmpty) {
      return '';
    }
    try {
      final jsonObject = jsonDecode(input);
      return jsonEncode(jsonObject);
    } on FormatException {
      throw const FormatException('Input is not valid JSON.');
    }
  }
}
