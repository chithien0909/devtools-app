import 'dart:convert';

class JsonService {
  String format(String json) {
    try {
      final decoded = jsonDecode(json);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (e) {
      return 'Invalid JSON string';
    }
  }

  String minify(String json) {
    try {
      final decoded = jsonDecode(json);
      return jsonEncode(decoded);
    } catch (e) {
      return 'Invalid JSON string';
    }
  }
}
