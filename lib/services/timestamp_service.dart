import 'package:intl/intl.dart';

class TimestampService {
  const TimestampService();

  static final DateFormat _formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<String> timestampToDate(String input) async {
    if (input.trim().isEmpty) {
      return '';
    }
    final milliseconds = int.tryParse(input.trim());
    if (milliseconds == null) {
      throw const FormatException('Enter a valid Unix timestamp (ms).');
    }
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      milliseconds,
      isUtc: true,
    ).toLocal();
    return _formatter.format(dateTime);
  }

  Future<String> dateToTimestamp(String input) async {
    if (input.trim().isEmpty) {
      return '';
    }
    try {
      final dateTime = _formatter.parse(input.trim(), true).toLocal();
      return dateTime.millisecondsSinceEpoch.toString();
    } on FormatException {
      throw const FormatException(
        'Use format yyyy-MM-dd HH:mm:ss (local time).',
      );
    }
  }
}
