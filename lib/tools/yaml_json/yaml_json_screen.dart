import 'package:flutter/material.dart';
import 'package:devtools_plus/services/yaml_json_service.dart';

class YamlJsonScreen extends StatefulWidget {
  const YamlJsonScreen({super.key});

  @override
  State<YamlJsonScreen> createState() => _YamlJsonScreenState();
}

class _YamlJsonScreenState extends State<YamlJsonScreen> {
  final YamlJsonService _service = const YamlJsonService();
  final TextEditingController _leftController = TextEditingController();
  final TextEditingController _rightController = TextEditingController();
  bool _leftIsYaml = true;
  bool _prettyJson = true;

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _convertLeftToRight() {
    try {
      final input = _leftController.text;
      final output = _leftIsYaml
          ? _service.yamlToJson(input, pretty: _prettyJson)
          : _service.jsonToYaml(input);
      setState(() => _rightController.text = output);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _swapSides() {
    setState(() {
      _leftIsYaml = !_leftIsYaml;
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
        title: const Text('YAML ⇄ JSON'),
        actions: [
          if (_leftIsYaml)
            Row(children: [
              const Text('Pretty JSON'),
              Switch(
                value: _prettyJson,
                onChanged: (v) => setState(() => _prettyJson = v),
              ),
            ]),
          IconButton(
            tooltip: 'Swap',
            onPressed: _swapSides,
            icon: const Icon(Icons.swap_horiz),
          ),
          IconButton(
            tooltip: 'Convert',
            onPressed: _convertLeftToRight,
            icon: const Icon(Icons.arrow_forward),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: _SideEditor(
              label: _leftIsYaml ? 'YAML' : 'JSON',
              controller: _leftController,
              hint: _leftIsYaml ? 'key: value' : '{"key": "value"}',
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: _SideEditor(
              label: _leftIsYaml ? 'JSON' : 'YAML',
              controller: _rightController,
              readOnly: true,
              hint: _leftIsYaml ? '{"key": "value"}' : 'key: value',
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        TextButton(
          onPressed: () => setState(() => _leftIsYaml = true),
          child: const Text('YAML → JSON'),
        ),
        TextButton(
          onPressed: () => setState(() => _leftIsYaml = false),
          child: const Text('JSON → YAML'),
        ),
      ],
    );
  }
}

class _SideEditor extends StatelessWidget {
  const _SideEditor({
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
