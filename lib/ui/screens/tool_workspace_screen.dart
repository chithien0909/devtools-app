import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';

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
                            else ...[
                              _SectionTitle(
                                icon: operation.icon,
                                title: operation.label,
                                subtitle: operation.description,
                              ),
                              const SizedBox(height: 16),
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
                                          ? () => viewModel.runCurrentOperation(
                                              tool.id,
                                            )
                                          : null,
                                      icon: session.isProcessing
                                          ? SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: colorScheme.onPrimary,
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
                                        : () => viewModel.moveOutputToInput(
                                            tool.id,
                                          ),
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
                                          ClipboardData(text: session.output),
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

class _ApiTesterPanel extends StatefulWidget {
  const _ApiTesterPanel();

  @override
  State<_ApiTesterPanel> createState() => _ApiTesterPanelState();
}

class _ApiTesterPanelState extends State<_ApiTesterPanel> {
  static const _methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD'];
  String _method = 'GET';
  final _urlCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final List<MapEntry<String, String>> _headers = [
    const MapEntry('Accept', 'application/json'),
  ];
  bool _useJson = true;
  String _responseMeta = '';
  String _responseHeaders = '';
  String _responseBody = '';
  bool _isSending = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _isSending = true);
    final sw = Stopwatch()..start();
    try {
      final uri = Uri.parse(_urlCtrl.text.trim());
      final headers = {for (final h in _headers) h.key: h.value};
      if (_useJson) {
        headers.putIfAbsent('Content-Type', () => 'application/json');
      }
      final method = _method.toUpperCase();
      final client = HttpClient();
      final request = await client.openUrl(method, uri);
      headers.forEach(request.headers.set);
      if (method != 'GET' && method != 'HEAD') {
        final body = _bodyCtrl.text;
        request.add(utf8.encode(body));
      }
      final httpResponse = await request.close();
      final bytes = await httpResponse.fold<List<int>>(<int>[], (b, d) {
        b.addAll(d);
        return b;
      });
      final elapsedMs = sw.elapsedMilliseconds;
      final text = utf8.decode(bytes);
      final size = bytes.length;
      final status = httpResponse.statusCode;
      final hdrBuf = StringBuffer();
      httpResponse.headers.forEach((name, values) {
        hdrBuf
          ..write(name)
          ..write(': ')
          ..writeln(values.join(', '));
      });
      setState(() {
        _responseMeta =
            'Status: $status    Time: ${elapsedMs}ms    Size: ${size}B';
        _responseHeaders = hdrBuf.toString();
        _responseBody = text;
      });
      client.close();
    } catch (e) {
      setState(() {
        _responseMeta = 'Request failed';
        _responseHeaders = '';
        _responseBody = e.toString();
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DropdownButton<String>(
              value: _method,
              items: _methods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _method = v ?? 'GET'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  hintText: 'https://api.example.com/path',
                ),
              ),
            ),
            const SizedBox(width: 8),
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
        const SizedBox(height: 12),
        Row(
          children: [
            Switch(
              value: _useJson,
              onChanged: (v) => setState(() => _useJson = v),
            ),
            const Text('JSON body'),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () =>
                  setState(() => _headers.add(const MapEntry('', ''))),
              child: const Text('Add header'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            for (int i = 0; i < _headers.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Header name',
                        ),
                        onChanged: (v) =>
                            _headers[i] = MapEntry(v, _headers[i].value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Header value',
                        ),
                        onChanged: (v) =>
                            _headers[i] = MapEntry(_headers[i].key, v),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _headers.removeAt(i)),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtrl,
          minLines: 6,
          maxLines: null,
          decoration: InputDecoration(
            hintText: _useJson ? '{ "name": "John" }' : 'Raw body',
          ),
        ),
        const SizedBox(height: 16),
        Text(_responseMeta, style: theme.textTheme.labelMedium),
        const SizedBox(height: 8),
        ExpansionTile(
          initiallyExpanded: true,
          title: const Text('Body'),
          children: [
            SelectableText(_responseBody.isEmpty ? '—' : _responseBody),
          ],
        ),
        ExpansionTile(
          title: const Text('Headers'),
          children: [
            SelectableText(_responseHeaders.isEmpty ? '—' : _responseHeaders),
          ],
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
