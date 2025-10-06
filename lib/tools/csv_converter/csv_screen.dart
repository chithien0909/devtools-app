import 'package:flutter/material.dart';
import 'package:devtools_plus/services/csv_service.dart';

class CsvConverterScreen extends StatefulWidget {
  const CsvConverterScreen({super.key});

  @override
  State<CsvConverterScreen> createState() => _CsvConverterScreenState();
}

class _CsvConverterScreenState extends State<CsvConverterScreen> {
  final CsvService _service = const CsvService();
  final TextEditingController _leftController = TextEditingController();
  final TextEditingController _rightController = TextEditingController();

  String _delimiter = ',';
  bool _leftIsCsv = true;
  bool _hasHeader = true;
  bool _includeHeaderOut = true;

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _convert() {
    try {
      final input = _leftController.text;
      final output = _leftIsCsv
          ? _service.csvToJson(input, delimiter: _delimiter, hasHeader: _hasHeader)
          : _service.jsonToCsv(input, delimiter: _delimiter, includeHeader: _includeHeaderOut);
      setState(() => _rightController.text = output);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _swap() {
    setState(() {
      _leftIsCsv = !_leftIsCsv;
      _leftController.text = _rightController.text;
      _rightController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV ⇄ JSON / TSV'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _delimiter,
              items: const [
                DropdownMenuItem(value: ',', child: Text('Comma ,')),
                DropdownMenuItem(value: '\t', child: Text('Tab \t')),
                DropdownMenuItem(value: ';', child: Text('Semicolon ;')),
                DropdownMenuItem(value: '|', child: Text('Pipe |')),
              ],
              onChanged: (v) => setState(() => _delimiter = v ?? ','),
            ),
          ),
          if (_leftIsCsv)
            Row(children: [
              const Text('Header'),
              Switch(value: _hasHeader, onChanged: (v) => setState(() => _hasHeader = v)),
            ])
          else
            Row(children: [
              const Text('Header'),
              Switch(value: _includeHeaderOut, onChanged: (v) => setState(() => _includeHeaderOut = v)),
            ]),
          IconButton(onPressed: _swap, icon: const Icon(Icons.swap_horiz)),
          IconButton(onPressed: _convert, icon: const Icon(Icons.arrow_forward)),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: _Side(
              label: _leftIsCsv ? 'CSV/TSV' : 'JSON',
              controller: _leftController,
              hint: _leftIsCsv ? 'a,b\n1,2' : '[{"a":1,"b":2}]',
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _Side(
              label: _leftIsCsv ? 'JSON' : 'CSV/TSV',
              controller: _rightController,
              readOnly: true,
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        TextButton(onPressed: () => setState(() => _leftIsCsv = true), child: const Text('CSV → JSON')),
        TextButton(onPressed: () => setState(() => _leftIsCsv = false), child: const Text('JSON → CSV')),
      ],
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: controller,
              expands: true,
              maxLines: null,
              minLines: null,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }
}
