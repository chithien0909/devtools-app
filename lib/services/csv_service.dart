import 'dart:convert';

import 'package:csv/csv.dart';

class CsvService {
  const CsvService();

  String csvToJson(String csvSource, {String delimiter = ',', bool hasHeader = true}) {
    if (csvSource.trim().isEmpty) return '';
    final converter = CsvToListConverter(fieldDelimiter: delimiter, eol: _detectEol(csvSource));
    final rows = converter.convert(csvSource);
    if (rows.isEmpty) return '[]';

    if (hasHeader) {
      final headers = rows.first.map((e) => e?.toString() ?? '').toList(growable: false);
      final List<Map<String, dynamic>> objects = [];
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final map = <String, dynamic>{};
        for (int j = 0; j < headers.length; j++) {
          final key = headers[j];
          final value = j < row.length ? row[j] : null;
          map[key] = value;
        }
        objects.add(map);
      }
      return const JsonEncoder.withIndent('  ').convert(objects);
    } else {
      return const JsonEncoder.withIndent('  ').convert(rows);
    }
  }

  String jsonToCsv(String jsonSource, {String delimiter = ',', bool includeHeader = true}) {
    if (jsonSource.trim().isEmpty) return '';
    final dynamic parsed = jsonDecode(jsonSource);
    final List<List<dynamic>> rows = [];

    if (parsed is List) {
      if (parsed.isEmpty) return '';
      if (parsed.first is Map) {
        final keys = _collectKeys(parsed.cast<Map>());
        if (includeHeader) rows.add(keys);
        for (final item in parsed.cast<Map>()) {
          rows.add(keys.map((k) => item[k]).toList());
        }
      } else {
        for (final item in parsed) {
          rows.add([item]);
        }
      }
    } else if (parsed is Map) {
      final entries = parsed.entries.map((e) => [e.key, e.value]).toList();
      if (includeHeader) rows.add(['key', 'value']);
      rows.addAll(entries);
    } else {
      rows.add([parsed]);
    }

    final converter = const ListToCsvConverter();
    return converter.convert(rows, fieldDelimiter: delimiter);
  }

  String _detectEol(String input) {
    if (input.contains('\r\n')) return '\r\n';
    if (input.contains('\n')) return '\n';
    return '\n';
  }

  List<String> _collectKeys(List<Map> items) {
    final set = <String>{};
    for (final m in items) {
      for (final key in m.keys) {
        set.add(key.toString());
      }
    }
    return set.toList();
  }
}
