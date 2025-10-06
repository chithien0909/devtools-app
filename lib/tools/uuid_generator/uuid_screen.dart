import 'package:devtools_plus/tools/uuid_generator/uuid_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UuidGeneratorScreen extends StatefulWidget {
  const UuidGeneratorScreen({super.key});

  @override
  State<UuidGeneratorScreen> createState() => _UuidGeneratorScreenState();
}

class _UuidGeneratorScreenState extends State<UuidGeneratorScreen> {
  final _service = UuidService();
  final _outputController = TextEditingController();
  final _bulkCountController = TextEditingController(text: '10');
  
  String _selectedVersion = 'v4';
  bool _bulkMode = false;

  void _generateSingle() {
    String uuid;
    switch (_selectedVersion) {
      case 'v1':
        uuid = _service.generateV1();
        break;
      case 'v4':
        uuid = _service.generateV4();
        break;
      case 'v7':
        uuid = _service.generateV7();
        break;
      default:
        uuid = _service.generateV4();
    }
    setState(() {
      _outputController.text = uuid;
    });
  }

  void _generateBulk() {
    final count = int.tryParse(_bulkCountController.text) ?? 10;
    if (count < 1 || count > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Count must be between 1 and 1000')),
      );
      return;
    }
    final uuids = _service.generateBulk(count: count, version: _selectedVersion);
    setState(() {
      _outputController.text = uuids.join('\n');
    });
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'UUID/GUID Generator',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'v1', label: Text('UUID v1')),
                      ButtonSegment(value: 'v4', label: Text('UUID v4')),
                      ButtonSegment(value: 'v7', label: Text('UUID v7')),
                    ],
                    selected: {_selectedVersion},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _selectedVersion = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bulk Generation'),
              value: _bulkMode,
              onChanged: (value) {
                setState(() {
                  _bulkMode = value;
                });
              },
            ),
            if (_bulkMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _bulkCountController,
                decoration: const InputDecoration(
                  labelText: 'Count (1-1000)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _bulkMode ? _generateBulk : _generateSingle,
              icon: const Icon(Icons.refresh),
              label: Text(_bulkMode ? 'Generate Bulk' : 'Generate UUID'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Output',
                        style: theme.textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copy to clipboard',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _outputController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedVersion == 'v1'
                  ? 'UUID v1: Time-based, includes MAC address'
                  : _selectedVersion == 'v4'
                      ? 'UUID v4: Random, most commonly used'
                      : 'UUID v7: Time-ordered for databases',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _outputController.dispose();
    _bulkCountController.dispose();
    super.dispose();
  }
}
