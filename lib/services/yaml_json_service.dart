import 'dart:convert';

import 'package:yaml/yaml.dart' as y;

class YamlJsonService {
  const YamlJsonService();

  String yamlToJson(String yamlSource, {bool pretty = true}) {
    if (yamlSource.trim().isEmpty) return '';
    final dynamic parsed = y.loadYaml(yamlSource);
    final dynamic normalized = _normalizeYaml(parsed);
    return pretty
        ? const JsonEncoder.withIndent('  ').convert(normalized)
        : jsonEncode(normalized);
  }

  String jsonToYaml(String jsonSource) {
    if (jsonSource.trim().isEmpty) return '';
    final dynamic parsed = jsonDecode(jsonSource);
    final buffer = StringBuffer();
    _writeYaml(parsed, buffer, 0);
    return buffer.toString();
  }

  dynamic _normalizeYaml(dynamic value) {
    if (value is Map) {
      return Map.fromEntries(value.entries.map(
        (e) => MapEntry(e.key.toString(), _normalizeYaml(e.value)),
      ));
    }
    if (value is Iterable) {
      return value.map(_normalizeYaml).toList();
    }
    return value;
  }

  void _writeYaml(dynamic value, StringBuffer out, int indent) {
    if (value is Map) {
      for (final entry in value.entries) {
        _indent(out, indent);
        out.write('${entry.key}:');
        final v = entry.value;
        if (v is Map || v is List) {
          out.write('\n');
          _writeYaml(v, out, indent + 2);
        } else if (v is String) {
          out.write(' "');
          out.write(_escapeString(v));
          out.writeln('"');
        } else {
          out.writeln(' ${v.toString()}');
        }
      }
      return;
    }
    if (value is List) {
      for (final item in value) {
        _indent(out, indent);
        out.write('-');
        if (item is Map || item is List) {
          out.write('\n');
          _writeYaml(item, out, indent + 2);
        } else if (item is String) {
          out.write(' "');
          out.write(_escapeString(item));
          out.writeln('"');
        } else {
          out.writeln(' ${item.toString()}');
        }
      }
      return;
    }
    _indent(out, indent);
    if (value is String) {
      out.writeln('"${_escapeString(value)}"');
    } else {
      out.writeln(value.toString());
    }
  }

  void _indent(StringBuffer out, int indent) {
    for (int i = 0; i < indent; i++) {
      out.write(' ');
    }
  }

  String _escapeString(String input) {
    return input
        .replaceAll('\\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n');
  }
}
