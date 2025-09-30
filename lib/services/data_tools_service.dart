import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:yaml/yaml.dart';

class CsvJsonResult {
  CsvJsonResult({required this.output, this.stats});

  final String output;
  final Map<String, Object?>? stats;
}

class DataToolsService {
  const DataToolsService();

  Future<String> csvToJson(String csvInput) async {
    try {
      final rows = const CsvToListConverter().convert(csvInput, eol: '\n');
      if (rows.isEmpty) {
        return '[]';
      }
      final headers = rows.first.map((cell) => cell.toString()).toList();
      final list = <Map<String, Object?>>[];
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        final map = <String, Object?>{};
        for (var j = 0; j < headers.length; j++) {
          map[headers[j]] = j < row.length ? row[j] : null;
        }
        list.add(map);
      }
      return const JsonEncoder.withIndent('  ').convert(list);
    } catch (error) {
      throw FormatException('Unable to parse CSV: $error');
    }
  }

  Future<String> jsonToCsv(String jsonInput) async {
    try {
      final decoded = json.decode(jsonInput);
      if (decoded is List) {
        if (decoded.isEmpty) {
          return '';
        }
        final headers = decoded.first is Map
            ? (decoded.first as Map).keys.map((key) => key.toString()).toList()
            : <String>['value'];
        final rows = <List<dynamic>>[headers];
        for (final item in decoded) {
          if (item is Map) {
            rows.add(headers.map((key) => item[key]).toList());
          } else {
            rows.add([item]);
          }
        }
        return const ListToCsvConverter().convert(rows);
      }
      if (decoded is Map) {
        final headers = decoded.keys.map((k) => k.toString()).toList();
        final rows = [headers, headers.map((key) => decoded[key]).toList()];
        return const ListToCsvConverter().convert(rows);
      }
      throw const FormatException('Provide a JSON object or array.');
    } catch (error) {
      throw FormatException('Unable to convert JSON: $error');
    }
  }

  Future<String> yamlToJson(String yamlInput) async {
    try {
      final parsed = loadYaml(yamlInput);
      final normalized = json.decode(json.encode(parsed));
      return const JsonEncoder.withIndent('  ').convert(normalized);
    } catch (error) {
      throw FormatException('Unable to parse YAML: $error');
    }
  }

  Future<String> jsonToYaml(String jsonInput) async {
    try {
      final parsed = json.decode(jsonInput);
      return _writeYaml(parsed);
    } catch (error) {
      throw FormatException('Unable to convert JSON: $error');
    }
  }

  String _writeYaml(Object? data) {
    final buffer = StringBuffer();
    void writeYaml(Object? value, {int indent = 0}) {
      final spaces = '  ' * indent;
      if (value is Map) {
        for (final entry in value.entries) {
          buffer.write('$spaces${entry.key}:');
          final child = entry.value;
          if (child is Map || child is List) {
            buffer.write('\n');
            writeYaml(child, indent: indent + 1);
          } else {
            buffer.write(' ${_scalarToString(child)}\n');
          }
        }
      } else if (value is List) {
        for (final item in value) {
          buffer.write('$spaces-');
          if (item is Map || item is List) {
            buffer.write('\n');
            writeYaml(item, indent: indent + 1);
          } else {
            buffer.write(' ${_scalarToString(item)}\n');
          }
        }
      } else {
        buffer.write('$spaces${_scalarToString(value)}\n');
      }
    }

    writeYaml(data);
    return buffer.toString();
  }

  String _scalarToString(Object? value) {
    if (value == null) return 'null';
    if (value is num || value is bool) return value.toString();
    final str = value.toString();
    if (str.contains(':') || str.contains('#') || str.contains('- ')) {
      return '"${str.replaceAll('"', '\\"')}"';
    }
    return str;
  }

  Map<String, Object?> textStats(String input) {
    final lines = input.split(RegExp(r'\r?\n'));
    final words = RegExp(r'\b\w+\b').allMatches(input).length;
    final chars = input.length;
    final bytes = utf8.encode(input).length;
    final blankLines = lines.where((line) => line.trim().isEmpty).length;
    return {
      'lines': lines.length,
      'blankLines': blankLines,
      'words': words,
      'characters': chars,
      'bytes': bytes,
    };
  }

  String convertTextCase(String input, TextCase targetCase) {
    switch (targetCase) {
      case TextCase.camel:
        return _toCamelCase(input, upperFirst: false);
      case TextCase.pascal:
        return _toCamelCase(input, upperFirst: true);
      case TextCase.snake:
        return _toDelimited(input, '_', lower: true);
      case TextCase.kebab:
        return _toDelimited(input, '-', lower: true);
      case TextCase.title:
        return _titleCase(input);
      case TextCase.upper:
        return input.toUpperCase();
      case TextCase.lower:
        return input.toLowerCase();
    }
  }

  RegExpResult testRegex(
    String pattern,
    String testInput, {
    bool multiLine = true,
    bool caseSensitive = true,
  }) {
    try {
      final regex = RegExp(
        pattern,
        multiLine: multiLine,
        caseSensitive: caseSensitive,
      );
      final matches = regex
          .allMatches(testInput)
          .map(
            (m) => RegexMatchDetail(
              start: m.start,
              end: m.end,
              value: m.group(0) ?? '',
            ),
          )
          .toList();
      return RegExpResult(matches: matches, hasError: false);
    } catch (error) {
      return RegExpResult(
        matches: const [],
        hasError: true,
        errorMessage: error.toString(),
      );
    }
  }

  String _toCamelCase(String input, {required bool upperFirst}) {
    final words = _splitWords(input);
    if (words.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      var word = words[i].toLowerCase();
      if (i == 0 && !upperFirst) {
        buffer.write(word);
      } else {
        buffer.write(word[0].toUpperCase() + word.substring(1));
      }
    }
    return buffer.toString();
  }

  String _toDelimited(String input, String delimiter, {bool lower = false}) {
    final words = _splitWords(input);
    final transformed = words
        .map((word) => lower ? word.toLowerCase() : word)
        .map((word) => word)
        .join(delimiter);
    return lower ? transformed.toLowerCase() : transformed;
  }

  String _titleCase(String input) {
    final words = _splitWords(input);
    return words
        .map(
          (w) => w.isEmpty
              ? ''
              : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  List<String> _splitWords(String input) {
    final normalized = input.replaceAll(RegExp(r'[_\-]'), ' ');
    final matches = RegExp(r'[A-Z]?[a-z]+|[A-Z]+(?![a-z])|\d+')
        .allMatches(normalized)
        .map((m) => m.group(0) ?? '')
        .where((w) => w.isNotEmpty)
        .toList();
    if (matches.isEmpty) {
      return normalized
          .split(RegExp(r'\s+'))
          .where((element) => element.isNotEmpty)
          .toList();
    }
    return matches;
  }
}

enum TextCase { camel, pascal, snake, kebab, title, upper, lower }

class RegExpResult {
  const RegExpResult({
    required this.matches,
    required this.hasError,
    this.errorMessage,
  });

  final List<RegexMatchDetail> matches;
  final bool hasError;
  final String? errorMessage;
}

class RegexMatchDetail {
  const RegexMatchDetail({
    required this.start,
    required this.end,
    required this.value,
  });

  final int start;
  final int end;
  final String value;
}
