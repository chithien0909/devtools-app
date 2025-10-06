import 'package:devtools_plus/tools/url_encoder/url_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlEncoderScreen extends StatefulWidget {
  const UrlEncoderScreen({super.key});

  @override
  State<UrlEncoderScreen> createState() => _UrlEncoderScreenState();
}

class _UrlEncoderScreenState extends State<UrlEncoderScreen> {
  final _service = UrlService();
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  
  String _mode = 'encode';
  String _encodingType = 'component';

  void _process() {
    try {
      String result = '';
      
      if (_mode == 'encode') {
        switch (_encodingType) {
          case 'component':
            result = _service.encodeUrl(_inputController.text);
            break;
          case 'query':
            result = _service.encodeQueryParameters(_inputController.text);
            break;
          case 'full':
            result = _service.encodeFull(_inputController.text);
            break;
        }
      } else {
        switch (_encodingType) {
          case 'component':
            result = _service.decodeUrl(_inputController.text);
            break;
          case 'query':
            result = _service.decodeQueryParameters(_inputController.text);
            break;
          case 'full':
            result = _service.decodeFull(_inputController.text);
            break;
        }
      }
      
      setState(() {
        _outputController.text = result;
      });
    } catch (e) {
      setState(() {
        _outputController.text = 'Error: ${e.toString()}';
      });
    }
  }

  void _parseQueryString() {
    try {
      final params = _service.parseQueryString(_inputController.text);
      final result = params.entries
          .map((e) => '${e.key} = ${e.value}')
          .join('\n');
      
      setState(() {
        _outputController.text = result.isEmpty ? 'No parameters found' : result;
      });
    } catch (e) {
      setState(() {
        _outputController.text = 'Error: ${e.toString()}';
      });
    }
  }

  void _copyToClipboard() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }
  }

  void _swap() {
    final temp = _inputController.text;
    setState(() {
      _inputController.text = _outputController.text;
      _outputController.text = temp;
      _mode = _mode == 'encode' ? 'decode' : 'encode';
    });
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
              'URL Encoder/Decoder',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'encode',
                        label: Text('Encode'),
                        icon: Icon(Icons.lock),
                      ),
                      ButtonSegment(
                        value: 'decode',
                        label: Text('Decode'),
                        icon: Icon(Icons.lock_open),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _mode = newSelection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'component',
                  label: Text('Component'),
                ),
                ButtonSegment(
                  value: 'query',
                  label: Text('Query Param'),
                ),
                ButtonSegment(
                  value: 'full',
                  label: Text('Full URL'),
                ),
              ],
              selected: {_encodingType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _encodingType = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Input',
                border: const OutlineInputBorder(),
                hintText: _mode == 'encode' 
                    ? 'Enter text to encode' 
                    : 'Enter encoded text to decode',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _process,
                  icon: const Icon(Icons.transform),
                  label: Text(_mode == 'encode' ? 'Encode' : 'Decode'),
                ),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: _swap,
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Swap'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _parseQueryString,
                  icon: const Icon(Icons.list),
                  label: const Text('Parse Query'),
                ),
              ],
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
              _encodingType == 'component'
                  ? 'Component: Encodes all special characters'
                  : _encodingType == 'query'
                      ? 'Query: Optimized for URL query parameters'
                      : 'Full: Encodes only characters invalid in URLs',
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
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
