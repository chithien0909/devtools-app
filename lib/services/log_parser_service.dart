import 'dart:convert';

class LogParserService {
  const LogParserService();

  Future<String> parse(String input) async {
    try {
      final jsonData = json.decode(input.trim());
      return _formatLogEntry(jsonData);
    } catch (e) {
      throw FormatException('Invalid JSON log entry: $e');
    }
  }

  String _formatLogEntry(dynamic data) {
    if (data is Map<String, dynamic>) {
      final buffer = StringBuffer();

      // Extract common log fields
      final timestamp = data['timestamp'] ?? data['time'] ?? data['@timestamp'];
      final level = data['level'] ?? data['severity'] ?? data['log_level'];
      final message = data['message'] ?? data['msg'] ?? data['text'];
      final service = data['service'] ?? data['app'] ?? data['application'];

      if (timestamp != null) {
        buffer.writeln('🕒 $timestamp');
      }

      if (level != null) {
        buffer.writeln('📊 Level: $level');
      }

      if (service != null) {
        buffer.writeln('🔧 Service: $service');
      }

      if (message != null) {
        buffer.writeln('💬 Message: $message');
      }

      // Add other fields
      final otherFields = <String, dynamic>{};
      data.forEach((key, value) {
        if (![
          'timestamp',
          'time',
          '@timestamp',
          'level',
          'severity',
          'log_level',
          'message',
          'msg',
          'text',
          'service',
          'app',
          'application',
        ].contains(key)) {
          otherFields[key] = value;
        }
      });

      if (otherFields.isNotEmpty) {
        buffer.writeln('\n📋 Additional Fields:');
        otherFields.forEach((key, value) {
          buffer.writeln('  • $key: $value');
        });
      }

      return buffer.toString();
    }

    return 'Parsed: $data';
  }
}
