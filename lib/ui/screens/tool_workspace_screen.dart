import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
                            const SizedBox(height: 24),
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
                                        : const Icon(Icons.play_arrow_rounded),
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
    final colorScheme = Theme.of(context).colorScheme;
    return SegmentedButton<int>(
      style: ButtonStyle(
        side: WidgetStateProperty.all(
          BorderSide(color: colorScheme.outlineVariant),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primary.withValues(alpha: 0.15)
              : Theme.of(context).cardColor,
        ),
      ),
      selected: {activeIndex},
      onSelectionChanged: (values) {
        final value = values.first;
        onChanged(value);
      },
      segments: [
        for (var index = 0; index < tool.operations.length; index++)
          ButtonSegment<int>(
            value: index,
            label: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(tool.operations[index].icon, size: 18),
                    const SizedBox(width: 6),
                    Text(tool.operations[index].label),
                    if (!tool.operations[index].isImplemented)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.construction, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  tool.operations[index].description,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
