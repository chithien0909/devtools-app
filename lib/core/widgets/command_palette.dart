import 'package:devtools_plus/core/registry/tool_registry.dart';
import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/providers/tool_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class CommandPalette extends ConsumerStatefulWidget {
  const CommandPalette({super.key});

  @override
  ConsumerState<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends ConsumerState<CommandPalette> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleToolSelected(String toolId) {
    final tool = ToolRegistry.findById(toolId);
    if (tool != null) {
      ref.read(activeToolProvider.notifier).state = tool.toToolModel();
      ref.read(recentToolsProvider.notifier).addTool(toolId);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = _controller.text;
    final results = ToolRegistry.search(query);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                      setState(() {
                        _selectedIndex = (_selectedIndex + 1) % results.length;
                      });
                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                      setState(() {
                        _selectedIndex = (_selectedIndex - 1 + results.length) % results.length;
                      });
                    } else if (event.logicalKey == LogicalKeyboardKey.enter && results.isNotEmpty) {
                      _handleToolSelected(results[_selectedIndex].id);
                    }
                  }
                },
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search tools...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final tool = results[index];
                  final isSelected = index == _selectedIndex;
                  final isFavorite = ref.watch(favoritesProvider).contains(tool.id);
                  
                  return ListTile(
                    selected: isSelected,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: tool.category.accentGradient,
                      ),
                      child: HugeIcon(
                        icon: tool.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(tool.name),
                    subtitle: Text(
                      tool.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isFavorite)
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tool.category.label,
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _handleToolSelected(tool.id),
                  );
                },
              ),
            ),
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No tools found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _KeyboardHint(label: '↑↓', description: 'Navigate'),
                  const SizedBox(width: 16),
                  _KeyboardHint(label: '↵', description: 'Select'),
                  const SizedBox(width: 16),
                  _KeyboardHint(label: 'Esc', description: 'Close'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyboardHint extends StatelessWidget {
  final String label;
  final String description;

  const _KeyboardHint({
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          description,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

void showCommandPalette(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const CommandPalette(),
  );
}
