import 'package:devtools_plus/services/url_builder_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UrlBuilderScreen extends StatefulWidget {
  const UrlBuilderScreen({super.key});

  @override
  State<UrlBuilderScreen> createState() => _UrlBuilderScreenState();
}

class _UrlBuilderScreenState extends State<UrlBuilderScreen> {
  final UrlBuilderService _service = const UrlBuilderService();

  final _scheme = TextEditingController(text: 'https');
  final _host = TextEditingController();
  final _port = TextEditingController();
  final _path = TextEditingController(text: '/');
  final _fragment = TextEditingController();
  final _userInfo = TextEditingController();
  final _urlInput = TextEditingController();
  final List<MapEntry<TextEditingController, TextEditingController>> _params =
      [];

  String _built = '';
  UrlValidationResult? _lastValidation;

  @override
  void dispose() {
    for (final p in _params) {
      p.key.dispose();
      p.value.dispose();
    }
    _scheme.dispose();
    _host.dispose();
    _port.dispose();
    _path.dispose();
    _fragment.dispose();
    _userInfo.dispose();
    _urlInput.dispose();
    super.dispose();
  }

  void _addParam([String k = '', String v = '']) {
    setState(() {
      _params.add(
        MapEntry(
          TextEditingController(text: k),
          TextEditingController(text: v),
        ),
      );
    });
  }

  void _parseUrl() {
    final result = _service.validate(_urlInput.text);
    setState(() => _lastValidation = result);
    if (!result.isValid || result.uri == null) {
      _show(result.error ?? 'Invalid URL');
      return;
    }
    try {
      final uri = result.uri!;
      setState(() {
        _scheme.text = uri.scheme;
        _host.text = uri.host;
        _port.text = uri.hasPort ? uri.port.toString() : '';
        _path.text = uri.path.isEmpty ? '/' : '/${uri.path}';
        _fragment.text = uri.fragment;
        _userInfo.text = uri.userInfo;
        _params.clear();
        uri.queryParametersAll.forEach((k, vals) {
          for (final v in vals) {
            _addParam(k, v);
          }
        });
      });
    } catch (e) {
      _show(e.toString());
    }
  }

  void _buildUrl() {
    final query = <String, String>{};
    for (final p in _params) {
      if (p.key.text.isEmpty) continue;
      query[p.key.text] = p.value.text;
    }
    final port = int.tryParse(_port.text);
    final uri = _service.build(
      scheme: _scheme.text,
      host: _host.text,
      port: port == null || port == 0 ? null : port,
      path: _path.text.startsWith('/') ? _path.text : '/${_path.text}',
      query: query,
      fragment: _fragment.text.isEmpty ? null : _fragment.text,
      userInfo: _userInfo.text.isEmpty ? null : _userInfo.text,
    );
    final normalized = _service.normalize(uri);
    setState(() {
      _built = normalized.toString();
      _lastValidation = _service.validate(_built);
    });
  }

  Future<void> _copyBuilt() async {
    if (_built.isEmpty) {
      _show('Build a URL first.');
      return;
    }
    final validation = _service.validate(_built);
    if (!validation.isValid || validation.uri == null) {
      _show(validation.error ?? 'Built URL is invalid.');
      return;
    }
    await Clipboard.setData(
      ClipboardData(text: _service.toClipboardPayload(validation.uri!)),
    );
    _show('Normalized URL copied to clipboard.');
  }

  Future<void> _shareBuilt() async {
    if (_built.isEmpty) {
      _show('Build a URL first.');
      return;
    }
    final validation = _service.validate(_built);
    if (!validation.isValid || validation.uri == null) {
      _show(validation.error ?? 'Built URL is invalid.');
      return;
    }
    final message = _service.toShareMessage(
      validation.uri!,
      label: _host.text.isEmpty ? null : _host.text,
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share URL'),
        content: SelectableText(
          message,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: message));
              Navigator.of(context).pop();
              _show('Share message copied.');
            },
            child: const Text('Copy Message'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearValidation() {
    if (_lastValidation != null) {
      setState(() => _lastValidation = null);
    }
  }

  void _show(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('URL Builder / Parser'),
        actions: [
          IconButton(
            tooltip: 'Parse URL',
            onPressed: _parseUrl,
            icon: const Icon(Icons.download),
          ),
          IconButton(
            tooltip: 'Build URL',
            onPressed: _buildUrl,
            icon: const Icon(Icons.upload),
          ),
          IconButton(
            tooltip: 'Validate input',
            onPressed: () {
              final result = _service.validate(_urlInput.text);
              setState(() => _lastValidation = result);
              _show(
                result.isValid
                    ? 'Valid URL'
                    : result.error ?? 'URL validation failed',
              );
            },
            icon: const Icon(Icons.verified),
          ),
          IconButton(
            tooltip: 'Copy built URL',
            onPressed: _copyBuilt,
            icon: const Icon(Icons.copy),
          ),
          IconButton(
            tooltip: 'Share built URL',
            onPressed: _shareBuilt,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: _urlInput,
            decoration: const InputDecoration(
              labelText: 'Paste URL to parse',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _clearValidation(),
          ),
          const SizedBox(height: 12),
          if (_lastValidation != null)
            Card(
              color: _lastValidation!.isValid
                  ? Theme.of(context).colorScheme.secondaryContainer
                  : Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: Icon(
                  _lastValidation!.isValid ? Icons.check_circle : Icons.error,
                  color: _lastValidation!.isValid ? Colors.green : Colors.red,
                ),
                title: Text(
                  _lastValidation!.isValid
                      ? 'URL looks valid.'
                      : _lastValidation!.error ?? 'Invalid URL.',
                ),
                subtitle: _lastValidation!.uri != null
                    ? Text(_lastValidation!.uri!.toString())
                    : null,
              ),
            ),
          if (_lastValidation != null) const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _scheme,
                  decoration: const InputDecoration(
                    labelText: 'Scheme',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _host,
                  decoration: const InputDecoration(
                    labelText: 'Host',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _port,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _path,
                  decoration: const InputDecoration(
                    labelText: 'Path',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _userInfo,
                  decoration: const InputDecoration(
                    labelText: 'User Info',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _fragment,
                  decoration: const InputDecoration(
                    labelText: 'Fragment',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Query params'),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _addParam, child: const Text('Add')),
            ],
          ),
          const SizedBox(height: 8),
          ..._params
              .map(
                (e) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: e.key,
                        decoration: const InputDecoration(
                          labelText: 'key',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: e.value,
                        decoration: const InputDecoration(
                          labelText: 'value',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
          const SizedBox(height: 12),
          if (_built.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  _built,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
