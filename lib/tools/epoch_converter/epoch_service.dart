import 'package:intl/intl.dart';

class EpochService {
  String epochToIso(int timestamp, {bool isMilliseconds = true}) {
    final dt = isMilliseconds
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return dt.toIso8601String();
  }

  String epochToFormatted(int timestamp, {bool isMilliseconds = true, String format = 'yyyy-MM-dd HH:mm:ss'}) {
    final dt = isMilliseconds
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat(format).format(dt);
  }

  int isoToEpoch(String isoString, {bool inMilliseconds = true}) {
    final dt = DateTime.parse(isoString);
    return inMilliseconds
        ? dt.millisecondsSinceEpoch
        : dt.millisecondsSinceEpoch ~/ 1000;
  }

  int nowEpoch({bool inMilliseconds = true}) {
    final now = DateTime.now();
    return inMilliseconds
        ? now.millisecondsSinceEpoch
        : now.millisecondsSinceEpoch ~/ 1000;
  }

  String epochToUtc(int timestamp, {bool isMilliseconds = true}) {
    final dt = isMilliseconds
        ? DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return dt.toIso8601String();
  }

  String epochToLocal(int timestamp, {bool isMilliseconds = true}) {
    final dt = isMilliseconds
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return dt.toLocal().toString();
  }

  Map<String, dynamic> epochToDetails(int timestamp, {bool isMilliseconds = true}) {
    final dt = isMilliseconds
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    
    return {
      'iso8601': dt.toIso8601String(),
      'utc': dt.toUtc().toString(),
      'local': dt.toLocal().toString(),
      'year': dt.year,
      'month': dt.month,
      'day': dt.day,
      'hour': dt.hour,
      'minute': dt.minute,
      'second': dt.second,
      'weekday': DateFormat('EEEE').format(dt),
      'timezone': dt.timeZoneName,
    };
  }
}
