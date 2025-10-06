import 'package:devtools_plus/tools/regex_tester/regex_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegexTesterScreen extends StatefulWidget {
  const RegexTesterScreen({super.key});

  @override
  State<RegexTesterScreen> createState() => _RegexTesterScreenState();
}

class _RegexTesterScreenState extends State<RegexTesterScreen> {
  final _service = RegexService();
  final _patternController = TextEditingController();
  final _testStringController = TextEditingController();
  final _replacementController = TextEditingController();
  
  bool _caseSensitive = true;
  bool _multiLine = false;
  bool _dotAll = false;
  bool _replaceMode = false;
  
  RegexMatchResult? _result;
  String? _replacedText;

  void _test() {
    setState(() {
      _result = _service.testRegex(
        _patternController.text,
        _testStringController.text,
        caseSensitive: _caseSensitive,
        multiLine: _multiLine,
        dotAll: _dotAll,
      );
      _replacedText = null;
    });
  }

  void _replace() {
    setState(() {
      _replacedText = _service.replaceMatches(
        _patternController.text,
        _testStringController.text,
        _replacementController.text,
        caseSensitive: _caseSensitive,
        multiLine: _multiLine,
        dotAll: _dotAll,
        replaceAll: true,
      );
      _result = null;
    });
  }

  void _escapePattern() {
    final escaped = _service.escapePattern(_patternController.text);
    setState(() {
      _patternController.text = escaped;
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard')),
    );
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
              'Regex Tester',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _patternController,
              decoration: InputDecoration(
                labelText: 'Regular Expression Pattern',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.pattern),
                hintText: r'\d+',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.format_quote),
                  tooltip: 'Escape special characters',
                  onPressed: _escapePattern,
                ),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Case Sensitive'),
                  selected: _caseSensitive,
                  onSelected: (value) {
                    setState(() {
                      _caseSensitive = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Multi-line'),
                  selected: _multiLine,
                  onSelected: (value) {
                    setState(() {
                      _multiLine = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Dot All'),
                  selected: _dotAll,
                  onSelected: (value) {
                    setState(() {
                      _dotAll = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _testStringController,
              decoration: const InputDecoration(
                labelText: 'Test String',
                border: OutlineInputBorder(),
                hintText: 'Enter text to test against the pattern',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Replace Mode'),
              value: _replaceMode,
              onChanged: (value) {
                setState(() {
                  _replaceMode = value;
                });
              },
            ),
            if (_replaceMode) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _replacementController,
                decoration: const InputDecoration(
                  labelText: 'Replacement String',
                  border: OutlineInputBorder(),
                  hintText: r'Use $1, $2 for capture groups',
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _replaceMode ? _replace : _test,
              icon: Icon(_replaceMode ? Icons.find_replace : Icons.search),
              label: Text(_replaceMode ? 'Replace All' : 'Test Pattern'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildResults(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_replacedText != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Replaced Text', style: theme.textTheme.titleMedium),
              IconButton(
                onPressed: () => _copyToClipboard(_replacedText!),
                icon: const Icon(Icons.copy),
                tooltip: 'Copy result',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _replacedText!,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_result == null) {
      return Center(
        child: Text(
          'Enter a pattern and test string, then click "Test Pattern"',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (!_result!.isValid) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: 12),
            Text(
              'Invalid Pattern',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _result!.error ?? 'Unknown error',
              style: TextStyle(color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _result!.matchCount > 0
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _result!.matchCount > 0 ? Icons.check_circle : Icons.info,
                color: _result!.matchCount > 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 12),
              Text(
                '${_result!.matchCount} match${_result!.matchCount == 1 ? '' : 'es'} found',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_result!.matchCount > 0)
          Expanded(
            child: ListView.builder(
              itemCount: _result!.matches.length,
              itemBuilder: (context, index) {
                final match = _result!.matches[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    title: Text(
                      'Match ${match.index + 1}: "${match.matched}"',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    subtitle: Text('Position: ${match.start}-${match.end}'),
                    children: [
                      if (match.groups.length > 1)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Capture Groups:',
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              ...match.groups.asMap().entries.skip(1).map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    'Group ${entry.key}: "${entry.value}"',
                                    style: const TextStyle(fontFamily: 'monospace'),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _patternController.dispose();
    _testStringController.dispose();
    _replacementController.dispose();
    super.dispose();
  }
}
