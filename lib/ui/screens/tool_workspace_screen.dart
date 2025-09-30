import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/models/developer_tool.dart';
import '../../viewmodels/tool_selector_view_model.dart';

class ToolWorkspaceScreen extends StatelessWidget {
  const ToolWorkspaceScreen({super.key, required this.tool});

  final DeveloperTool tool;

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolSelectorViewModel>(
      builder: (context, viewModel, _) {
        final colorScheme = Theme.of(context).colorScheme;
        final session = viewModel.sessionFor(tool.id);
        final operation = tool.operations[session.activeOperationIndex];
        final isQrScan = operation.id == 'qr_scan';
        final canRun = operation.isImplemented && !session.isProcessing;

        return Scaffold(
          body: Stack(
            children: [
              Hero(
                tag: 'tool-${tool.id}-background',
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tool.primaryColor, tool.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _WorkspaceAppBar(tool: tool),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _OperationSelector(
                              tool: tool,
                              activeIndex: session.activeOperationIndex,
                              onChanged: (index) =>
                                  viewModel.selectOperation(tool.id, index),
                            ),
                            const SizedBox(height: 16),
                            if (operation.id == 'api_tester')
                              const _ApiTesterPanel()
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SectionTitle(
                                    icon: operation.icon,
                                    title: operation.label,
                                    subtitle: operation.description,
                                  ),
                                  const SizedBox(height: 16),
                                  if (isQrScan)
                                    _QrScannerPanel(
                                      toolId: tool.id,
                                      viewModel: viewModel,
                                      session: session,
                                    )
                                  else ...[
                                    _InputField(
                                      controller: session.inputController,
                                      hint: operation.placeholder,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: canRun
                                                ? () => viewModel
                                                      .runCurrentOperation(
                                                        tool.id,
                                                      )
                                                : null,
                                            icon: session.isProcessing
                                                ? SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: colorScheme
                                                              .onPrimary,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.play_arrow_rounded,
                                                  ),
                                            label: Text(
                                              session.isProcessing
                                                  ? 'Processing...'
                                                  : operation.isImplemented
                                                  ? 'Run ${operation.label}'
                                                  : 'Planned feature',
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton.filledTonal(
                                          tooltip: 'Use result as input',
                                          onPressed: session.output.isEmpty
                                              ? null
                                              : () => viewModel
                                                    .moveOutputToInput(tool.id),
                                          icon: const Icon(
                                            Icons.flip_camera_android_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!operation.isImplemented) ...[
                                      const SizedBox(height: 12),
                                      _InfoBanner(
                                        message:
                                            'This utility is on the DevTools+ roadmap. Check the roadmap tab for delivery updates.',
                                      ),
                                    ],
                                  ],
                                  const SizedBox(height: 12),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    child: session.error == null
                                        ? const SizedBox.shrink()
                                        : _ErrorBanner(message: session.error!),
                                  ),
                                  const SizedBox(height: 16),
                                  _SectionTitle(
                                    icon: Icons.outbox_outlined,
                                    title: 'Output',
                                    subtitle:
                                        'Result updates as soon as processing completes.',
                                  ),
                                  const SizedBox(height: 12),
                                  _OutputPanel(
                                    content: session.output,
                                    onCopy: session.output.isEmpty
                                        ? null
                                        : () async {
                                            await Clipboard.setData(
                                              ClipboardData(
                                                text: session.output,
                                              ),
                                            );
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context)
                                                ..hideCurrentSnackBar()
                                                ..showSnackBar(
                                                  SnackBar(
                                                    content: const Text(
                                                      'Copied to clipboard',
                                                    ),
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                  ),
                                                );
                                            }
                                          },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkspaceAppBar extends StatelessWidget {
  const _WorkspaceAppBar({required this.tool});

  final DeveloperTool tool;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: colorScheme.onPrimary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tool.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tool.tagline,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'All tools',
          onPressed: () {
            context.read<ToolSelectorViewModel>().selectCategory(null);
            Navigator.of(context).maybePop();
          },
          icon: Icon(
            Icons.grid_view_rounded,
            color: colorScheme.onPrimary.withValues(alpha: 0.8),
          ),
        ),
        Icon(tool.icon, color: colorScheme.onPrimary.withValues(alpha: 0.75)),
      ],
    );
  }
}

class _OperationSelector extends StatelessWidget {
  const _OperationSelector({
    required this.tool,
    required this.activeIndex,
    required this.onChanged,
  });

  final DeveloperTool tool;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          for (var index = 0; index < tool.operations.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                selected: index == activeIndex,
                onSelected: (_) => onChanged(index),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                pressElevation: 0,
                avatar: Icon(
                  tool.operations[index].icon,
                  size: 16,
                  color: index == activeIndex
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                ),
                label: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 220),
                  child: Text(
                    tool.operations[index].label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                labelStyle: theme.textTheme.bodySmall,
                selectedColor: colorScheme.primary,
                backgroundColor: theme.cardColor,
                shape: StadiumBorder(
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                visualDensity: const VisualDensity(
                  horizontal: -2,
                  vertical: -2,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, this.hint});

  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 6,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hint ?? 'Paste or type your content here...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => controller.clear(),
        ),
      ),
    );
  }
}

class _OutputPanel extends StatelessWidget {
  const _OutputPanel({required this.content, required this.onCopy});

  final String content;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Processed output',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Copy result',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_outlined),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (content.isEmpty)
            Text(
              'Run the tool to see the transformation here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            SelectableText(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'Roboto Mono',
              ),
            ),
        ],
      ),
    );
  }
}

enum _RequestBodyMode { raw, formData }

class _EditablePair {
  _EditablePair({String key = '', String value = ''})
    : keyController = TextEditingController(text: key),
      valueController = TextEditingController(text: value);

  final TextEditingController keyController;
  final TextEditingController valueController;

  MapEntry<String, String> toEntry() =>
      MapEntry(keyController.text.trim(), valueController.text.trim());

  bool get hasData =>
      keyController.text.trim().isNotEmpty &&
      valueController.text.trim().isNotEmpty;

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class _ApiRequestSnapshot {
  const _ApiRequestSnapshot({
    required this.method,
    required this.url,
    required this.headers,
    required this.bodyMode,
    required this.rawBody,
    required this.formData,
  });

  final String method;
  final String url;
  final List<MapEntry<String, String>> headers;
  final _RequestBodyMode bodyMode;
  final String rawBody;
  final List<MapEntry<String, String>> formData;
}

class _ApiHistoryEntry {
  _ApiHistoryEntry({required this.snapshot, required this.savedAt});

  final _ApiRequestSnapshot snapshot;
  final DateTime savedAt;
}

class _ApiResponseData {
  const _ApiResponseData({
    required this.statusCode,
    required this.reasonPhrase,
    required this.elapsedMs,
    required this.sizeBytes,
    required this.headers,
    required this.body,
    this.parsedJson,
  });

  final int statusCode;
  final String? reasonPhrase;
  final int elapsedMs;
  final int sizeBytes;
  final Map<String, String> headers;
  final String body;
  final dynamic parsedJson;

  bool get isJson => parsedJson != null;
}

class _ApiTesterPanel extends StatefulWidget {
  const _ApiTesterPanel();

  @override
  State<_ApiTesterPanel> createState() => _ApiTesterPanelState();
}

class _ApiTesterPanelState extends State<_ApiTesterPanel> {
  static const _methods = <String>[
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
    'HEAD',
    'OPTIONS',
  ];

  String _method = 'GET';
  final _urlCtrl = TextEditingController(
    text: 'https://api.example.com/resource',
  );
  final _rawBodyCtrl = TextEditingController(text: '{\n  "key": "value"\n}');
  final List<_EditablePair> _headers = [
    _EditablePair(key: 'Content-Type', value: 'application/json'),
    _EditablePair(key: 'Accept', value: 'application/json'),
  ];
  final List<_EditablePair> _formFields = [_EditablePair()];
  _RequestBodyMode _bodyMode = _RequestBodyMode.raw;
  bool _isSending = false;
  String? _error;
  _ApiResponseData? _response;
  String? _curlCommand;
  _ApiRequestSnapshot? _latestSnapshot;
  final List<_ApiHistoryEntry> _history = [];

  bool get _methodAllowsBody => !{'GET', 'HEAD'}.contains(_method);

  @override
  void dispose() {
    _urlCtrl.dispose();
    _rawBodyCtrl.dispose();
    for (final header in _headers) {
      header.dispose();
    }
    for (final field in _formFields) {
      field.dispose();
    }
    super.dispose();
  }

  void _addHeader() {
    setState(() => _headers.add(_EditablePair()));
  }

  void _removeHeader(int index) {
    if (index >= 0 && index < _headers.length) {
      final removed = _headers.removeAt(index);
      removed.dispose();
      setState(() {});
    }
  }

  void _addFormField() {
    setState(() => _formFields.add(_EditablePair()));
  }

  void _removeFormField(int index) {
    if (index >= 0 && index < _formFields.length) {
      final removed = _formFields.removeAt(index);
      removed.dispose();
      setState(() {
        if (_formFields.isEmpty) {
          _formFields.add(_EditablePair());
        }
      });
    }
  }

  _EditablePair? _findHeaderPair(String name) {
    final lookup = name.toLowerCase();
    for (final pair in _headers) {
      if (pair.keyController.text.trim().toLowerCase() == lookup) {
        return pair;
      }
    }
    return null;
  }

  void _syncSuggestedContentType(_RequestBodyMode mode) {
    final target = mode == _RequestBodyMode.raw
        ? 'application/json'
        : 'application/x-www-form-urlencoded';
    final pair = _findHeaderPair('Content-Type');
    if (pair == null) {
      _headers.insert(0, _EditablePair(key: 'Content-Type', value: target));
      return;
    }
    final current = pair.valueController.text.trim().toLowerCase();
    if (current.isEmpty ||
        current == 'application/json' ||
        current == 'application/x-www-form-urlencoded') {
      pair.valueController.text = target;
    }
  }

  Map<String, String> _collectHeaders() {
    final headers = <String, String>{};
    for (final pair in _headers) {
      final entry = pair.toEntry();
      if (entry.key.isNotEmpty && entry.value.isNotEmpty) {
        headers[entry.key] = entry.value;
      }
    }

    if (_methodAllowsBody) {
      if (_bodyMode == _RequestBodyMode.raw) {
        headers.putIfAbsent('Content-Type', () => 'application/json');
      } else {
        headers.putIfAbsent(
          'Content-Type',
          () => 'application/x-www-form-urlencoded',
        );
      }
    }
    return headers;
  }

  List<MapEntry<String, String>> _collectFormData() {
    return _formFields
        .map((pair) => pair.toEntry())
        .where((entry) => entry.key.isNotEmpty)
        .toList();
  }

  Future<void> _send() async {
    final urlText = _urlCtrl.text.trim();
    if (urlText.isEmpty) {
      setState(() {
        _error = 'Provide a request URL to continue.';
        _response = null;
      });
      return;
    }

    Uri? uri;
    try {
      uri = Uri.parse(urlText);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$urlText');
      }
    } catch (_) {
      setState(() {
        _error =
            'Unable to parse the URL. Double-check the address and try again.';
        _response = null;
      });
      return;
    }

    final headers = _collectHeaders();
    final formData = _collectFormData();
    final rawBody = _rawBodyCtrl.text;
    _latestSnapshot = _ApiRequestSnapshot(
      method: _method,
      url: uri.toString(),
      headers: headers.entries.toList(),
      bodyMode: _bodyMode,
      rawBody: rawBody,
      formData: formData,
    );

    setState(() {
      _isSending = true;
      _error = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final request = http.Request(_method, uri);
      request.headers.addAll(headers);
      if (_methodAllowsBody) {
        if (_bodyMode == _RequestBodyMode.raw) {
          request.body = rawBody;
        } else {
          final fields = {for (final entry in formData) entry.key: entry.value};
          request.bodyFields = fields;
        }
      }

      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      stopwatch.stop();
      client.close();

      dynamic parsedJson;
      try {
        if (response.body.isNotEmpty) {
          parsedJson = jsonDecode(response.body);
        }
      } catch (_) {
        parsedJson = null;
      }

      final responseHeaders = <String, String>{};
      response.headers.forEach((key, value) {
        responseHeaders[key] = value;
      });

      final data = _ApiResponseData(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        elapsedMs: stopwatch.elapsedMilliseconds,
        sizeBytes: response.bodyBytes.length,
        headers: responseHeaders,
        body: response.body,
        parsedJson: parsedJson,
      );

      if (mounted) {
        setState(() {
          _response = data;
          _error = null;
          _curlCommand = _buildCurlCommand(
            request.method,
            uri.toString(),
            headers,
            _methodAllowsBody
                ? (request.bodyBytes.isEmpty
                      ? rawBody
                      : utf8.decode(request.bodyBytes))
                : '',
          );
        });
      }
    } catch (error) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _response = null;
          _error = error.toString();
          _curlCommand = _buildCurlCommand(
            _method,
            uri?.toString() ?? urlText,
            headers,
            _methodAllowsBody ? rawBody : '',
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _buildCurlCommand(
    String method,
    String url,
    Map<String, String> headers,
    String body,
  ) {
    final buffer = StringBuffer('curl -X $method');
    buffer.write(" '$url'");
    headers.forEach((key, value) {
      buffer.write(
        " -H '${_escapeSingleQuotes(key)}: ${_escapeSingleQuotes(value)}'",
      );
    });
    if (body.trim().isNotEmpty) {
      buffer.write(" -d '${_escapeSingleQuotes(body)}'");
    }
    return buffer.toString();
  }

  String _escapeSingleQuotes(String value) => value.replaceAll("'", "'\\''");

  Future<void> _copyToClipboard(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _saveToHistory() {
    final snapshot = _latestSnapshot;
    if (snapshot == null) {
      return;
    }
    setState(() {
      _history.insert(
        0,
        _ApiHistoryEntry(snapshot: snapshot, savedAt: DateTime.now()),
      );
      if (_history.length > 10) {
        _history.removeLast();
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Saved to history')));
    }
  }

  void _applySnapshot(_ApiRequestSnapshot snapshot) {
    for (final header in _headers) {
      header.dispose();
    }
    for (final field in _formFields) {
      field.dispose();
    }

    setState(() {
      _method = snapshot.method;
      _urlCtrl.text = snapshot.url;
      _bodyMode = snapshot.bodyMode;
      _rawBodyCtrl.text = snapshot.rawBody;

      _headers
        ..clear()
        ..addAll(
          snapshot.headers.isEmpty
              ? [_EditablePair()]
              : snapshot.headers.map(
                  (entry) => _EditablePair(key: entry.key, value: entry.value),
                ),
        );

      _formFields
        ..clear()
        ..addAll(
          snapshot.formData.isEmpty
              ? [_EditablePair()]
              : snapshot.formData.map(
                  (entry) => _EditablePair(key: entry.key, value: entry.value),
                ),
        );
      _syncSuggestedContentType(_bodyMode);
    });
  }

  Widget _buildHeaderRow(int index) {
    final pair = _headers[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: pair.keyController,
              decoration: const InputDecoration(hintText: 'Header name'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: pair.valueController,
              decoration: const InputDecoration(hintText: 'Header value'),
            ),
          ),
          IconButton(
            tooltip: 'Remove header',
            onPressed: () => _removeHeader(index),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldRow(int index) {
    final pair = _formFields[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: pair.keyController,
              decoration: const InputDecoration(hintText: 'Key'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: pair.valueController,
              decoration: const InputDecoration(hintText: 'Value'),
            ),
          ),
          IconButton(
            tooltip: 'Remove field',
            onPressed: () => _removeFormField(index),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonNode(dynamic value, {String? label}) {
    if (value is Map<String, dynamic>) {
      final entries = value.entries.toList();
      return ExpansionTile(
        title: Text(
          label != null
              ? '$label (${entries.length})'
              : 'Object (${entries.length})',
          style: const TextStyle(fontFamily: 'Roboto Mono'),
        ),
        children: entries
            .map((entry) => _buildJsonNode(entry.value, label: entry.key))
            .toList(),
      );
    }
    if (value is List) {
      return ExpansionTile(
        title: Text(
          label != null
              ? '$label [${value.length}]'
              : 'Array [${value.length}]',
          style: const TextStyle(fontFamily: 'Roboto Mono'),
        ),
        children: [
          for (int i = 0; i < value.length; i++)
            _buildJsonNode(value[i], label: '[$i]'),
        ],
      );
    }
    final display = value == null ? 'null' : value.toString();
    return ListTile(
      dense: true,
      title: Text(
        label ?? 'value',
        style: const TextStyle(fontFamily: 'Roboto Mono'),
      ),
      subtitle: Text(
        display,
        style: const TextStyle(fontFamily: 'Roboto Mono'),
      ),
    );
  }

  Widget _buildResponseSection(ThemeData theme) {
    final response = _response;
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Response', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          )
        else if (response != null) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Chip(
                label: Text(
                  'Status ${response.statusCode}${response.reasonPhrase != null ? ' (${response.reasonPhrase})' : ''}',
                ),
                avatar: const Icon(Icons.http, size: 16),
              ),
              Chip(
                label: Text('Time ${response.elapsedMs} ms'),
                avatar: const Icon(Icons.timer_outlined, size: 16),
              ),
              Chip(
                label: Text('Size ${response.sizeBytes} B'),
                avatar: const Icon(Icons.straighten, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: response.isJson
                    ? () => _copyToClipboard(
                        const JsonEncoder.withIndent(
                          '  ',
                        ).convert(response.parsedJson),
                        'Response JSON copied',
                      )
                    : null,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('Copy JSON'),
              ),
              TextButton.icon(
                onPressed: _curlCommand == null
                    ? null
                    : () => _copyToClipboard(
                        _curlCommand!,
                        'Copied cURL command',
                      ),
                icon: const Icon(Icons.terminal_outlined),
                label: const Text('Copy as cURL'),
              ),
              TextButton.icon(
                onPressed: _latestSnapshot == null ? null : _saveToHistory,
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Save to history'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            initiallyExpanded: response.isJson,
            title: const Text('Body'),
            children: [
              if (response.isJson)
                _buildJsonNode(response.parsedJson)
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    response.body.isEmpty ? '—' : response.body,
                    style: const TextStyle(fontFamily: 'Roboto Mono'),
                  ),
                ),
            ],
          ),
          ExpansionTile(
            title: const Text('Headers'),
            children: [
              if (response.headers.isEmpty)
                const ListTile(title: Text('No headers in response.'))
              else
                ...response.headers.entries.map(
                  (entry) => ListTile(
                    dense: true,
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontFamily: 'Roboto Mono'),
                    ),
                    subtitle: Text(
                      entry.value,
                      style: const TextStyle(fontFamily: 'Roboto Mono'),
                    ),
                  ),
                ),
            ],
          ),
        ] else
          Text(
            'Send a request to inspect the response here.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildHistorySection(ThemeData theme) {
    if (_history.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('History', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._history.map((entry) {
          final snapshot = entry.snapshot;
          final subtitle = '${snapshot.method} • ${snapshot.url}';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('Saved ${_formatTimestamp(entry.savedAt)}'),
              trailing: IconButton(
                tooltip: 'Load request',
                icon: const Icon(Icons.north_west_outlined),
                onPressed: () => _applySnapshot(snapshot),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatTimestamp(DateTime value) {
    final now = DateTime.now();
    if (now.difference(value).inMinutes < 1) {
      return 'just now';
    }
    if (now.difference(value).inHours < 1) {
      final mins = now.difference(value).inMinutes;
      return '$mins minute${mins == 1 ? '' : 's'} ago';
    }
    if (now.difference(value).inDays < 1) {
      final hours = now.difference(value).inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }
    final days = now.difference(value).inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Request', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 140,
                      child: DropdownMenu<String>(
                        initialSelection: _method,
                        label: const Text('Method'),
                        dropdownMenuEntries: [
                          for (final method in _methods)
                            DropdownMenuEntry(value: method, label: method),
                        ],
                        onSelected: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() => _method = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _urlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Request URL',
                          hintText: 'https://api.example.com/resource',
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isSending ? null : _send,
                      icon: _isSending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                      label: const Text('Send'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SegmentedButton<_RequestBodyMode>(
                      segments: const [
                        ButtonSegment(
                          value: _RequestBodyMode.raw,
                          label: Text('Raw JSON'),
                          icon: Icon(Icons.code),
                        ),
                        ButtonSegment(
                          value: _RequestBodyMode.formData,
                          label: Text('Form-data'),
                          icon: Icon(Icons.table_rows_outlined),
                        ),
                      ],
                      selected: {_bodyMode},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _bodyMode = selection.first;
                          _syncSuggestedContentType(_bodyMode);
                        });
                      },
                    ),
                    TextButton.icon(
                      onPressed: _addHeader,
                      icon: const Icon(Icons.add),
                      label: const Text('Header'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    for (int i = 0; i < _headers.length; i++)
                      _buildHeaderRow(i),
                  ],
                ),
                const Divider(height: 32),
                if (_methodAllowsBody)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _bodyMode == _RequestBodyMode.raw
                        ? TextField(
                            key: const ValueKey('raw'),
                            controller: _rawBodyCtrl,
                            minLines: 8,
                            maxLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Request body',
                              hintText: '{ "key": "value" }',
                            ),
                          )
                        : Column(
                            key: const ValueKey('form'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  for (int i = 0; i < _formFields.length; i++)
                                    _buildFormFieldRow(i),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _addFormField,
                                  icon: const Icon(Icons.add_circle_outline),
                                  label: const Text('Add field'),
                                ),
                              ),
                            ],
                          ),
                  )
                else
                  Text(
                    'Body not sent with $_method requests.',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _buildResponseSection(theme),
          ),
        ),
        const SizedBox(height: 16),
        _buildHistorySection(theme),
      ],
    );
  }
}

class _QrScannerPanel extends StatefulWidget {
  const _QrScannerPanel({
    required this.toolId,
    required this.viewModel,
    required this.session,
  });

  final String toolId;
  final ToolSelectorViewModel viewModel;
  final ToolSession session;

  @override
  State<_QrScannerPanel> createState() => _QrScannerPanelState();
}

class _QrScannerPanelState extends State<_QrScannerPanel> {
  late final MobileScannerController _controller;
  bool _hasCaptured = false;
  String? _lastValue;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
    _hasCaptured = widget.session.output.isNotEmpty;
    _lastValue = widget.session.output.isEmpty ? null : widget.session.output;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasCaptured) {
        return;
      }
      _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) {
        continue;
      }
      if (_hasCaptured && value == _lastValue) {
        return;
      }
      _lastValue = value;
      setState(() => _hasCaptured = true);
      widget.viewModel.setSessionState(
        widget.toolId,
        output: value,
        clearError: true,
      );
      _controller.stop();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('QR code detected')));
      }
      break;
    }
  }

  void _restartScanning() {
    setState(() => _hasCaptured = false);
    widget.viewModel.setSessionState(widget.toolId, clearError: true);
    _controller.start();
  }

  Future<void> _toggleTorch(TorchState state) async {
    if (state == TorchState.unavailable) {
      return;
    }
    try {
      await _controller.toggleTorch();
    } on MobileScannerException catch (error) {
      final message =
          error.errorDetails?.message ??
          'Unable to toggle torch (${error.errorCode.name})';
      widget.viewModel.setSessionState(widget.toolId, error: message);
    } catch (error) {
      widget.viewModel.setSessionState(widget.toolId, error: error.toString());
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } on MobileScannerException catch (error) {
      final message =
          error.errorDetails?.message ??
          'Unable to switch camera (${error.errorCode.name})';
      widget.viewModel.setSessionState(widget.toolId, error: message);
    } catch (error) {
      widget.viewModel.setSessionState(widget.toolId, error: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  fit: BoxFit.cover,
                  onDetect: _handleDetection,
                  errorBuilder: (context, error) {
                    final message =
                        error.errorDetails?.message ??
                        'Camera unavailable (${error.errorCode.name})';
                    widget.viewModel.setSessionState(
                      widget.toolId,
                      error: message,
                    );
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.6),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    _hasCaptured
                        ? 'Scan stored. Use "Scan again" to capture another code.'
                        : 'Align the QR code inside the frame to capture it instantly.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_hasCaptured)
                  Container(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text('QR captured', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final torchState = state.torchState;
                final isOn = torchState == TorchState.on;
                final unavailable = torchState == TorchState.unavailable;
                return IconButton.filledTonal(
                  tooltip: unavailable
                      ? 'Torch unavailable on this device'
                      : isOn
                      ? 'Turn torch off'
                      : 'Turn torch on',
                  onPressed: unavailable
                      ? null
                      : () => _toggleTorch(torchState),
                  icon: Icon(
                    isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                  ),
                );
              },
            ),
            ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (context, state, _) {
                final facing = state.cameraDirection;
                final cameraCount = state.availableCameras;
                final canSwitch = cameraCount == null || cameraCount > 1;
                return IconButton.filledTonal(
                  tooltip: canSwitch ? 'Switch camera' : 'Single-camera device',
                  onPressed: canSwitch ? _switchCamera : null,
                  icon: Icon(
                    facing == CameraFacing.back
                        ? Icons.camera_front_outlined
                        : Icons.camera_rear_outlined,
                  ),
                );
              },
            ),
            OutlinedButton.icon(
              onPressed: _hasCaptured ? _restartScanning : null,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Scan again'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _hasCaptured
              ? 'Copy the decoded value from the output below or start a new scan.'
              : 'The scanner pauses automatically once a code is detected.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
