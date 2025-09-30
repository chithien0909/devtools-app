import 'dart:convert';

class LogParserService {
  const LogParserService();

  Future<String> parse(String input) async {
    if (input.trim().isEmpty) {
      return '';
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(input);
    } on FormatException {
      throw const FormatException('Input is not valid JSON.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object at the top level.');
    }

    final buffer = StringBuffer();
    const keyOrder = ['level', 'time', 'msg'];

    void writeEntry(String key, dynamic value) {
      if (value == null) {
        return;
      }
      if (value is Map || value is List) {
        const encoder = JsonEncoder.withIndent('  ');
        buffer
          ..writeln('$key:')
          ..writeln(encoder.convert(value));
      } else {
        buffer.writeln('$key: $value');
      }
    }

    for (final key in keyOrder) {
      if (decoded.containsKey(key)) {
        writeEntry(key, decoded[key]);
      }
    }

    final remainingKeys = decoded.keys.where((key) => !keyOrder.contains(key));

    for (final key in remainingKeys) {
      writeEntry(key, decoded[key]);
    }

    return buffer.toString().trimRight();
  }
}
